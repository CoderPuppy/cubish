defmodule Cubish.Mixfile do
	use Mix.Project

	def project, do: [
		app: :cubish,
		version: "0.0.1",
		elixir: "~> 0.15.2-dev",
		deps: deps
	]

	# Configuration for the OTP application
	#
	# Type `mix help compile.app` for more information
	def application, do: [
		applications: [:logger],
		mod: {Cubish, []}
	]

	# Dependencies can be Hex packages:
	#
	#   {:mydep, "~> 0.3.0"}
	#
	# Or git/path repositories:
	#
	#   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
	#
	# Type `mix help deps` for more examples and options
	defp deps, do: [
		{:loise, git: "https://github.com/lfex/loise", ref: "master"},
		{:lfe, git: "https://github.com/rvirding/lfe", ref: "master", override: true},
		{:ltest, git: "https://github.com/lfex/ltest", ref: "master", override: true}
	]
end