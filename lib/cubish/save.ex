defmodule Cubish.Save do
	use GenServer

	defstruct [:dir, :loader, :generator, :pid, :supervisor, :worlds_sup]

	defmodule State do
		defstruct [
			voxels: %{ nil => %Cubish.NothingVoxel{} },
			items: %{},
			worlds: %{},
			save: nil
		]
	end

	def start_link(dir, sup, opts \\ []) do
		case GenServer.start_link(__MODULE__, {dir, sup}, opts) do
			{:ok, pid} ->
				GenServer.cast pid, :spawn_procs
				{:ok, pid}

			res -> res
		end
	end
	def init({dir, sup}) do
		nothing_block = %Cubish.NothingVoxel{}
		nothing_item = %Cubish.NothingItem{}
		state = %State{
			save: %Cubish.Save{
				dir: dir,
				supervisor: sup,
				pid: self
			}
		}
		state = %{ state |
			voxels: state.voxels
				|> Dict.put(nil, nothing_block)
				|> Dict.put(nothing_block, nil),

			items: state.items
				|> Dict.put(nil, nothing_item)
				|> Dict.put(nothing_item, nil),
		}
		{:ok, state}
	end

	def handle_cast(:spawn_procs, state = %State{}) do
		{:ok, worlds_sup} = Supervisor.start_child state.save.supervisor, Cubish.WorldsSupervisor.spec(restart: :temporary)
		{:ok, loader} = Supervisor.start_child state.save.supervisor, Supervisor.Spec.worker(Cubish.Chunk.Loader, [], restart: :temporary)
		{:ok, generator} = Supervisor.start_child state.save.supervisor, Supervisor.Spec.worker(Cubish.World.Generator, [], restart: :temporary)
		{:noreply, %{ state |
			save: %{ state.save |
				worlds_sup: worlds_sup,
				loader: loader,
				generator: generator
			}
		}}
	end

	def get(pid), do: GenServer.call(pid, :get)
	def handle_call(:get, _from, state = %State{save: save}), do: {:reply, save, state}

	def get_voxel(%Cubish.Save{pid: pid}, id), do: GenServer.call(pid, {:get_voxel, id})
	def handle_call({:get_voxel, id}, _from, state = %State{voxels: voxels}), do: {:reply, voxels[id], state}

	def get_voxels(%Cubish.Save{pid: pid}), do: GenServer.call(pid, :get_voxels)
	def handle_call(:get_voxels, _from, state = %State{voxels: voxels}), do: {:reply, voxels, state}

	def get_item(%Cubish.Save{pid: pid}, id), do: GenServer.call(pid, {:get_item, id})
	def handle_call({:get_item, id}, _from, state = %State{items: items}), do: {:reply, items[id], state}

	def get_items(%Cubish.Save{pid: pid}), do: GenServer.call(pid, :get_items)
	def handle_call(:get_items, _from, state = %State{items: items}), do: {:reply, items, state}

	def start_world(save, id, provider), do: GenServer.call(save.pid, {:start_world, {id, provider}})
	def handle_call({:start_world, {id, provider}}, _from, state = %State{worlds: worlds}) do
		{:ok, world} = Cubish.WorldsSupervisor.start_world(state.save, id, provider)
		{:reply, world, %{state | worlds: worlds |> Dict.put(world.id, world) }}
	end
end

defimpl String.Chars, for: Cubish.Save do
	def to_string(save) do
		"#{inspect save.pid}"
	end
end