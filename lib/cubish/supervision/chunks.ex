defmodule Cubish.ChunksSupervisor do
	use Supervisor

	def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, opts)
	def spec(opts \\ []), do: supervisor(__MODULE__, [], opts)
	def init(:ok), do: supervise([], strategy: :one_for_one)

	def start_chunk(chunk) do
		case Supervisor.start_child(chunk.world.chunks_sup, Cubish.ChunkHolder.spec(chunk)) do
			{:ok, pid} ->
				{:ok, Cubish.ChunkHolder.get pid}

			res -> res
		end
	end
end