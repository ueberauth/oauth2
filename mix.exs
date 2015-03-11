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
      {:hackney, "~> 1.0.6"},
      {:httpoison, "~> 0.6.2"},
      {:poison, "~> 1.3.1"},
      {:cowboy, "~> 1.0", only: :test},
      {:plug, "~> 0.11.1"},
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
