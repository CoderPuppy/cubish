defmodule Cubish.WorldSupervisor do
	use Supervisor

	def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, opts)
	def spec(opts \\ []), do: supervisor(__MODULE__, [], opts)
	def init(:ok), do: supervise([], strategy: :one_for_all)
end