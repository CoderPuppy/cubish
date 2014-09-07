defmodule Cubish.Save do
	defstruct [
		voxels: %{ nil => %Cubish.NothingVoxel{} },
		items: %{},
		worlds: %{}
	]

	def new do
		save = %Cubish.Save{}
		nothing_block = %Cubish.NothingVoxel{}
		nothing_item = %Cubish.NothingItem{}
		save = %{ save |
			voxels: save.voxels
				|> Dict.put(nil, nothing_block)
				|> Dict.put(nothing_block, nil),

			items: save.items
				|> Dict.put(nil, nothing_item)
				|> Dict.put(nothing_item, nil),
		}
		save
	end
end