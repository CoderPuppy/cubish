defmodule Cubish.WorldHolder do
	use GenServer

	def start_link(world = %Cubish.World{}, opts \\ []), do: GenServer.start_link(__MODULE__, world, opts)
	def get(holder), do: GenServer.call(holder, :get)
	def load_chunk(holder, pos), do: GenServer.call(holder, {:load_chunk, pos})

	def init(world), do: {:ok, world}
	def handle_call(:get, _from, world), do: {:reply, world, world}
	def handle_call({:load_chunk, pos}, _from, world) do
		if world.chunks |> Dict.has_key?(pos) do
			{:reply, world.chunks[pos], world}
		else
			{:ok, chunk_holder} = Cubish.ChunkHolder.start_link Cubish.Chunk.new(self, pos)
			world = %{ world | chunks: world.chunks |> Dict.put(pos, chunk_holder) }
			{:reply, chunk_holder, world}
		end
	end
end