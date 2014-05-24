defmodule ExNeo4j.Mixfile do
  use Mix.Project

  def project do
    [app: :neo4j,
     version: "0.0.1",
     elixir: "~> 0.13.2",
     elixirc_options: options(Mix.env),
     deps: deps]
  end

  def options(env) when env in [:dev, :test], do: [exlager_level: :debug]
  def options(env) when env in [:prod], do: [exlager_level: :warning]

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpotion, :exlager],
     mod: {ExNeo4j, []}]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:jazz      , github: "meh/jazz"            } ,
      {:exactor   , github: "sasa1977/exactor"    } ,
      {:httpotion , github: "myfreeweb/httpotion" } ,
      {:exlager   , github: "khia/exlager"        }
    ]
  end
end
