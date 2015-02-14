defmodule OAuth2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :oauth2,
      version: "0.0.4",
      elixir: "~> 1.0",
      deps: deps,
      package: package,
      description: "An Elixir OAuth 2.0 Client Library"
    ]
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:hackney, "~> 1.0"},
      {:httpoison, "~> 0.6.0"},
      {:poison, "~> 1.3"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 0.10.0"},
    ]
  end

  defp package do
    [
      contributors: ["Sonny Scroggin"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/scrogson/oauth2"}
    ]
  end
end
