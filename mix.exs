defmodule ExNeo4j.Mixfile do
  use Mix.Project
  use Mix.Config

  if Mix.env in [:dev, :test], do: config(:lager, log_level: :debug)
  if Mix.env == :prod, do: config(:lager, log_level: :warning)

  def project do
    [app: :neo4j,
     version: "0.0.1",
     elixir: "~> 0.14.0",
     deps: deps]
  end

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
      {:jazz      , "~> 0.1.1"                    } ,
      {:exactor   , github: "sasa1977/exactor"    } ,
      {:httpotion , github: "myfreeweb/httpotion" } ,
      {:exlager   , github: "khia/exlager"        }
    ]
  end
end
