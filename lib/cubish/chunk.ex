defmodule Cubish.Chunk do
	@size 16

	defstruct [:save, :world, :pos, :voxel_data, :struct_data]

	# x -> y -> z
	# so rows along the x axis repeated along the y axis, all that repeated along the z axis

	def new(world, pos) do
		%Cubish.Chunk{
			save: world.save,
			world: world,
			pos: pos,
			voxel_data: [{nil, @size |> :math.pow(3)}],
			struct_data: [{nil, @size |> :math.pow(3)}]
		}
	end

	def generate(chunk), do: generate(chunk, Cubish.World.Provider.generator(chunk.world.provider, chunk.pos))
	def generate(chunk, generator), do: %{ chunk | voxel_data: generate_data(chunk, generator), struct_data: [{nil, @size |> :math.pow(3)}] }

	def generate_data(chunk), do: generate_data(chunk, Cubish.World.Provider.generator(chunk.world.provider, chunk.pos))
	def generate_data(chunk, generator) do
		nothing = Cubish.Save.get_voxel chunk.save, nil
		{cx, cy, cz} = chunk.pos
		{ox, oy, oz} = {cx * @size, cy * @size, cz * @size}
		offset_fn = fn {x, y, z} ->
			{ox + x, oy + y, oz + z}
		end
		_generate(chunk.save, offset_fn, nothing, generator, {@size, @size, @size}, [])
	end

	defp _generate(save, offset_fn, nothing, generator, pos, voxel_data)
	defp _generate(_save, _offset_fn, _nothing, _generator, {0, 0, 0}, voxel_data), do: voxel_data
	defp _generate(save, offset_fn, nothing, generator, pos = {x, y, z}, voxel_data) do
		voxel = Cubish.Chunk.Generator.generate(generator, nothing, offset_fn.({x, y, z}))
		# IO.inspect({x, y, z, voxel, voxel_data})
		_generate(save, offset_fn, nothing, generator, _next_pos(pos), _add_elem(voxel_data, Cubish.Save.get_voxel(save, voxel)))
	end

	defp _next_pos({0, 0, z}), do: {@size, @size, z - 1}
	defp _next_pos({0, y, z}), do: {@size, y - 1, z}
	defp _next_pos({x, y, z}), do: {x - 1, y, z}

	defp _add_elem(data, elem)
	defp _add_elem([{elem, n} | tail], elem), do: [{elem, n + 1} | tail]
	defp _add_elem(data, elem), do: [{elem, 1} | data]

	# def get(chunk, x, y, z)
	# def set(chunk, x, y, z, block)
end