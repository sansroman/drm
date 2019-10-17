defmodule Drm.MixProject do
  use Mix.Project

  def project do
    [
      app: :drm,
      name: "remote docker repo manager",
      version: "0.0.1",
      source_url: "https://github.com/sansroman/drm/issues",
      escript: escript_config(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      { :httpoison, "~> 1.6.1" },
      { :poison, "~> 4.0.1"},
      { :ex_doc, "~> 0.21.2"},
      { :earmark, "~> 1.4.1"}
    ]
  end

  defp escript_config do
    [
      main_module: Drm.CLI
    ]
  end
end
