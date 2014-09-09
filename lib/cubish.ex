defmodule Cubish do
	use Application

	def start(_type, _args) do
		Cubish.SavesSupervisor.start_link
	end
end