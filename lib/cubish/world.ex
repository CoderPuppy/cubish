defmodule Cubish.World do
	defstruct [:save_holder, :id, :provider, :chunks]

	def new(save_holder, id, provider) do
		%Cubish.World{
			save_holder: save_holder,
			id: id,
			provider: provider,
			chunks: %{}
		}
	end
end