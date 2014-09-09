defmodule Cubish.Chunk.Loader do
	use GenServer

	def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, :ok, opts)
end