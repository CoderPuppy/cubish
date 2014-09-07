defprotocol Cubish.Chunk.Generator do
	def generate(generator, nothing, x, y, z)
end

defmodule Cubish.Chunk.Generator.Empty do
	defstruct []
end

defimpl Cubish.Chunk.Generator, for: Cubish.Chunk.Generator.Empty do
	def generate(_self, nothing, _x, _y, _z), do: nothing
end