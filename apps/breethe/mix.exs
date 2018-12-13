defmodule Breethe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :breethe,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Breethe.Application, []},
      extra_applications: [:logger, :runtime_tools, :httpoison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.0"},
      {:ecto_enum, "~> 1.1"},
      {:geo_postgis, "~> 3.0"},
      {:ex_machina, "~> 2.1", only: :test},
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:bypass, "~> 1.0", only: :test},
      {:timex, "~> 3.1"},
      {:mox, "~> 0.3", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
