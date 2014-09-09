defmodule Cubish.WorldsSupervisor do
	use Supervisor

	def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, opts)
	def spec(opts \\ []), do: supervisor(__MODULE__, [], opts)
	def init(:ok), do: supervise([], strategy: :one_for_one)

	def start_world(save, id, provider) do
		case Supervisor.start_child(save.worlds_sup, Cubish.WorldSupervisor.spec) do
			{:ok, sup} ->
				case Supervisor.start_child(sup, Cubish.World.spec(save, id, provider, sup)) do
					{:ok, pid} ->
						{:ok, Cubish.World.get pid}

					res -> res
				end

			res -> res
		end
	end
end