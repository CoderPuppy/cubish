defmodule Cubish.Chunk do
	@size 16

	defstruct [:world_holder, :pos, :data]

	# x -> y -> z
	# so rows along the x axis repeated along the y axis, all that repeated along the z axis

	def new(world_holder, pos) do
		%Cubish.Chunk{
			world_holder: world_holder,
			pos: pos,
			data: [{nil, @size |> :math.pow(3)}]
		}
	end

	def generate(chunk, generator) do
		nothing = Cubish.SaveHolder.get(Cubish.WorldHolder.get(chunk.world_holder).save_holder).voxels[nil]
		{cx, cy, cz} = chunk.pos
		{ox, oy, oz} = {cx * @size, cy * @size, cz * @size}
		offset_fn = fn {x, y, z} ->
			{ox + x, oy + y, oz + z}
		end
		%{ chunk | data: _generate(offset_fn, nothing, generator, {@size, @size, @size}, []) }
	end

	defp _generate(offset_fn, nothing, generator, pos, output)
	defp _generate(offset_fn, nothing, _generator, {0, 0, 0}, output), do: output
	defp _generate(offset_fn, nothing, generator, pos = {x, y, z}, output) do
		voxel = Cubish.Chunk.Generator.generate(generator, nothing, offset_fn.({x, y, z}))
		IO.inspect({x, y, z, voxel, output})
		_continue_generate(offset_fn, nothing, generator, pos, _add_voxel(output, voxel))
	end

	defp _continue_generate(offset_fn, nothing, generator, pos, output)
	defp _continue_generate(offset_fn, nothing, generator, {0, 0, z}, output), do: _generate(offset_fn, nothing, generator, {@size, @size, z - 1}, output)
	defp _continue_generate(offset_fn, nothing, generator, {0, y, z}, output), do: _generate(offset_fn, nothing, generator, {@size, y - 1, z}, output)
	defp _continue_generate(offset_fn, nothing, generator, {x, y, z}, output), do: _generate(offset_fn, nothing, generator, {x - 1, y, z}, output)

	defp _add_voxel(output, voxel)
	defp _add_voxel([{voxel, n} | tail], voxel), do: [{voxel, n + 1} | tail]
	defp _add_voxel(output, voxel), do: [{voxel, 1} | output]

	# def get(chunk, x, y, z)
	# def set(chunk, x, y, z, block)
end