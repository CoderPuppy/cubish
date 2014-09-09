defmodule Cubish.SavesSupervisor do
	use Supervisor

	def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, Dict.put(opts, :name, __MODULE__))
	def spec(opts \\ []), do: supervisor(__MODULE__, [], opts)
	def init(:ok), do: supervise([], strategy: :one_for_one)

	def start_save(dir) do
		case Supervisor.start_child(__MODULE__, supervisor(Cubish.SaveSupervisor, [])) do
			{:ok, sup} ->
				case Supervisor.start_child(sup, worker(Cubish.Save, [dir, sup])) do
					{:ok, pid} ->
						{:ok, Cubish.Save.get pid}

					res -> res
				end

			res -> res
		end
	end
end