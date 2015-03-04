defmodule ExNeo4j.Mixfile do
  use Mix.Project
  use Mix.Config

  def project do
    [app: :neo4j,
     version: "0.0.7",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpoison, :inflex, :chronos, :poison],
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
      { :poison    , "~> 1.3.0"        } ,
      { :chronos   , "~> 0.3.5"        } ,
      { :inflex    , "~> 1.0.0"        } ,
      { :httpoison , "~> 0.6"          } ,

      { :meck, "~> 0.8.2", only: :test }
    ]
  end
end
