defmodule Cubish.SaveHolder do
	use GenServer

	def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, :ok, opts)
	def get(holder), do: GenServer.call(holder, :get)
	def start_world(world = %Cubish.World{save_holder: holder}), do: _start_world(holder, world.id, Cubish.WorldHolder.start_link(world))
	defp _start_world(holder, id, {:ok, world_holder}) do
		GenServer.cast(holder, {:world, id, world_holder})
		{:ok, world_holder}
	end
	defp _start_world(_holder, _id, res), do: res

	def init(:ok), do: {:ok, Cubish.Save.new}
	def handle_call(:get, _from, save), do: {:reply, save, save}
	def handle_cast({:world, id, world_holder}, save) do
		{:noreply, %{save | worlds: save.worlds |> Dict.put(id, world_holder) }}
	end
end