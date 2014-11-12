defmodule OAuth2.Mixfile do
  use Mix.Project

  @description """
  Elixir OAuth2 Client
  """

  def project do
    [
      app: :oauth2,
      version: "0.0.1",
      elixir: "~> 1.0",
      deps: deps,
      description: @description,
      package: [
        contributors: ["Sonny Scroggin", "Nate West"],
        licence: "MIT",
        links: [github: "https://github.com/scrogson/oauth2"]
      ]
    ]
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:hackney, "~> 0.14.1"},
      {:httpoison, "~> 0.5.0"},
      {:poison, "~> 1.2.0"},
      {:plug, "~> 0.8.2"},
      {:cowboy, "~> 1.0.0", only: :dev},
    ]
  end
end
