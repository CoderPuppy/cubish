defprotocol Cubish.World.Provider do
	def generator(provider, cx, cy, cz)
end

defmodule Cubish.World.Provider.Empty do
	defstruct []
end

defimpl Cubish.World.Provider, for: Cubish.World.Provider.Empty do
	def generator(_self, _cx, _cy, _cz), do: %Cubish.Chunk.Generator.Empty{}
end