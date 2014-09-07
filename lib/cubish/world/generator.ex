defmodule Cubish.World.Generator do
	use GenServer

	def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, :ok, opts)
	def queue(generator, world_holder, cpos), do: GenServer.cast(generator, {:queue, {world_holder, cpos}})

	def init(:ok), do: {:ok, {[], HashSet.new}}
	def handle_cast({:queue, job}, {queue, processing}), do: {:noreply, {[job | queue], processing}}
	def handle_cast({:done, job}, {queue, processing}), do: {:noreply, {queue, Set.delete(processing, job)}}
	def handle_call(:pull, _from, data = {[], _processing}), do: {:reply, nil, data}
	def handle_call(:pull, _from, {queue, processing}) do
		job = List.last(queue)
		{:reply, job, { List.delete_at(queue, -1), Set.put(processing, job) }}
	end
end