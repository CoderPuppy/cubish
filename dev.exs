{:ok, save_holder} = Cubish.SaveHolder.start_link
{:ok, world_holder} = Cubish.SaveHolder.start_world Cubish.World.new(save_holder, :living, %Cubish.World.Provider.Empty{})
chunk_holder = Cubish.WorldHolder.load_chunk(world_holder, {0, 0, 0})
{:ok, generator} = Cubish.World.Generator.start_link
Cubish.World.Generator.queue generator, world_holder, {0, 0, 0}

IO.inspect save: Cubish.SaveHolder.get(save_holder)
IO.inspect world: Cubish.WorldHolder.get(world_holder)
IO.inspect chunk: Cubish.ChunkHolder.get(chunk_holder)