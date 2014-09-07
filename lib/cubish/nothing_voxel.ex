defmodule Cubish.NothingVoxel do
	defstruct []

	defimpl Cubish.Voxel, for: Cubish.NothingVoxel do
		def unlocalized_name(_world, _x, _y, _z), do: {"cubish:voxel.nothing"}
		def is_air(_world, _x, _y, _z), do: true
		def is_replacable(_world, _x, _y, _z), do: true
		def hitbox(_world, _x, _y, _z, _for), do: nil
	end
end