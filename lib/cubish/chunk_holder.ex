defmodule Cubish.ChunkHolder do
	use GenServer

	def start_link(chunk = %Cubish.Chunk{}, opts \\ []), do: GenServer.start_link(__MODULE__, chunk, opts)
	def get(holder), do: GenServer.call(holder, :get)
	def generate(holder, generator), do: GenServer.cast(holder, {:generate, generator})

	def init(chunk), do: {:ok, chunk}
	def handle_call(:get, _from, chunk), do: {:reply, chunk, chunk}
	def handle_cast({:generate, generator}, chunk), do: {:noreply, chunk |> Cubish.Chunk.generate(generator)}
end