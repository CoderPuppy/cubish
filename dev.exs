defmodule Testing do
	def get_tree(supervisor) do
		supervisor
			|> Supervisor.which_children
			|> Enum.map(fn
				{id, child, :supervisor, [module]} -> {module, get_tree(child)}
				{id, child, :worker, [module]} -> module
			end)
	end
end
{:ok, save} = Cubish.SavesSupervisor.start_save Path.join([ File.cwd!, "test_save" ])
Process.link save.pid
IO.inspect save: save

world = Cubish.Save.start_world save, :living, %Cubish.World.Provider.Empty{}
Process.link world.pid
IO.inspect world: world

chunk_holder = Cubish.World.load_chunk(world, {0, 0, 0})
Process.link chunk_holder.pid
IO.inspect chunk: Cubish.ChunkHolder.get_chunk(chunk_holder)

IO.inspect Testing.get_tree(Cubish.SavesSupervisor)