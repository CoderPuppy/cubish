defprotocol Cubish.Plugin do
	use Behaviour

	defcallback load :: Cubish.Plugin.t
end