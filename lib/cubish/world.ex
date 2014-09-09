defmodule Cubish.World do
	use GenServer

	defstruct [:save, :id, :provider, :pid, :supervisor, :chunks_sup]

	defmodule State do
		defstruct [:world, chunks: %{}]
	end

	def start_link(save, id, provider, sup, opts \\ []) do
		case GenServer.start_link(__MODULE__, {save, id, provider, sup}, opts) do
			{:ok, pid} ->
				GenServer.cast pid, :spawn_procs
				{:ok, pid}

			res -> res
		end
	end
	def spec(save, id, provider, sup, opts \\ []), do: Supervisor.Spec.worker(__MODULE__, [save, id, provider, sup], opts)
	def init({save, id, provider, sup}) do
		world = %Cubish.World{
			save: save,
			id: id,
			provider: provider,
			pid: self,
			supervisor: sup
		}
		{:ok, %State{ world: world }}
	end

	def handle_cast(:spawn_procs, state) do
		{:ok, chunks_sup} = Supervisor.start_child state.world.supervisor, Cubish.ChunksSupervisor.spec(restart: :temporary)
		{:noreply, %{ state | world: %{ state.world | chunks_sup: chunks_sup } }}
	end

	def get(pid), do: GenServer.call(pid, :get)
	def handle_call(:get, _from, state = %State{world: world}), do: {:reply, world, state}

	def load_chunk(%Cubish.World{pid: pid}, cpos), do: GenServer.call(pid, {:load_chunk, cpos})
	def handle_call({:load_chunk, pos}, _from, state) do
		if state.chunks |> Dict.has_key?(pos) do
			{:reply, state.chunks[pos], state}
		else
			{:ok, chunk_holder} = Cubish.ChunksSupervisor.start_chunk Cubish.Chunk.new(state.world, pos)
			state = %{ state | chunks: state.chunks |> Dict.put(pos, chunk_holder) }
			# IO.puts "queueing the loading of #{inspect chunk_holder.pos}"
			Cubish.World.Generator.queue state.world.save.generator, chunk_holder
			{:reply, chunk_holder, state}
		end
	end
end

defimpl String.Chars, for: Cubish.World do
	def to_string(world) do
		"#{world.id}"
	end
end