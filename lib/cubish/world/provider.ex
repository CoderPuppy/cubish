defprotocol Cubish.World.Provider do
	def generator(provider, cpos)
end

defmodule Cubish.World.Provider.Empty do
	defstruct []
end

defimpl Cubish.World.Provider, for: Cubish.World.Provider.Empty do
	def generator(_self, _cpos), do: %Cubish.Chunk.Generator.Empty{}
end