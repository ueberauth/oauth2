defmodule OAuth2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :oauth2,
      version: "0.0.1",
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
      {:hackney, "~> 0.14.1"},
      {:httpoison, "~> 0.5.0"},
      {:poison, "~> 1.2.0"},
      {:cowboy, "~> 1.0", only: :test},
      {:plug, "~> 0.9.0"},
    ]
  end

  defp package do
    [
      contributors: ["Sonny Scroggin"],
      licence: "MIT",
      links: %{github: "https://github.com/scrogson/oauth2"}
    ]
  end
end
