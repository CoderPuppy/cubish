defmodule Cubish.JobQueue do
	use GenServer

	defmodule State do
		defstruct func: nil, queue: [], processing: %{}, waiting: [], workers: HashSet.new
	end

	def start_link(func, worker_count, opts \\ []), do: GenServer.start_link(__MODULE__, {func, worker_count}, opts)
	def init({func, worker_count}) do
		state = %State{func: func}
		state = _spawn_workers(state, worker_count)
		{:ok, state}
	end

	defp _spawn_workers(state, 0), do: state
	defp _spawn_workers(state, worker_count) do
		state
			|> _spawn_worker
			|> _spawn_workers(worker_count - 1)
	end

	defp _spawn_worker(state = %State{}) do
		{:ok, pid} = Cubish.JobQueue.Worker.spawn(self, state.func)
		monitor = Process.monitor(pid)
		%State{workers: state.workers |> Set.put({pid, monitor})}
	end

	defp _assign_job(worker, state = %State{ queue: [job|queue] }) do
		Cubish.JobQueue.Worker.assign worker, job
		%State{ queue: queue, processing: state.processing |> Dict.put(worker, job) }
	end

	def queue(job_queue, job), do: GenServer.cast(job_queue, {:queue, job})
	def handle_cast({:queue, job}, state = %State{}), do: {:noreply, _handle_queue(job, state)}
	defp _handle_queue(job, state = %State{waiting: [worker | waiting]}) do
		# IO.puts "assigning #{job} to waiting worker: #{inspect worker}"
		Cubish.JobQueue.Worker.assign worker, job
		%{state | waiting: waiting}
	end
	defp _handle_queue(job, state = %State{}) do
		# IO.puts "queueing #{job}"
		%{state | queue: [job | state.queue]}
	end
	
	def wait(job_queue), do: GenServer.cast(job_queue, {:wait, self})
	def handle_cast({:wait, worker}, state), do: {:noreply, _handle_wait(worker, state)}
	defp _handle_wait(worker, state = %State{queue: []}) do
		# IO.puts "#{inspect worker} waiting for a job"
		%{state | waiting: state.waiting ++ [worker] }
	end
	defp _handle_wait(worker, state), do: _assign_job(worker, state)

	def done(job_queue), do: GenServer.cast(job_queue, {:done, self})
	def handle_cast({:done, worker}, state = %State{}) do
		# IO.puts "#{state.processing[worker]} finished on #{inspect worker}"
		%{state | processing: state.processing |> Dict.delete(worker) }
	end

	def handle_info(msg = {:DOWN, _monitor, :process, worker, _reason}, state) do
		IO.inspect msg
		if Set.member?(state.workers, worker) do
			state = %{state | workers: state.workers |> Set.delete(worker)}

			case Dict.fetch(state.processing, worker) do
				{:ok, job} ->
					state = _handle_queue(job, %{ state | processing: state.processing |> Dict.delete(worker) })

				:error ->
			end
		end
		state = _spawn_worker(state)
		{:noreply, state}
	end

	defmodule Worker do
		use GenServer

		def spawn(job_queue, func, opts \\ []), do: GenServer.start(__MODULE__, {job_queue, func}, opts)
		def init({job_queue, func}) do
			Cubish.JobQueue.wait job_queue
			{:ok, {job_queue, func}}
		end

		def assign(worker, job) do
			# IO.puts "assigning #{job} to #{inspect worker}"
			GenServer.cast(worker, {:assign, job})
		end
		def handle_cast({:assign, job}, {job_queue, {module, func, args}}) do
			args = [job|args]
			# IO.puts "processing #{job} on #{inspect self}"
			# IO.puts "running #{module}.#{func} #{args |> Enum.join(", ")}"
			apply module, func, args
			Cubish.JobQueue.done job_queue
			Cubish.JobQueue.wait job_queue
		end
	end
end