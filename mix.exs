defmodule OAuth2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :oauth2,
      version: "0.3.0",
      elixir: "~> 1.0",
      deps: deps,
      package: package,
      name: "OAuth2",
      description: "An Elixir OAuth 2.0 Client Library",
      source_url: "https://github.com/scrogson/oauth2",
      homepage_url: "https://github.com/scrogson/oauth2"
    ]
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:hackney, "~> 1.0"},
      {:httpoison, "~> 0.6"},
      {:poison, "~> 1.3"},
      {:cowboy, "~> 1.0", only: :test},
      {:plug, "~> 1.0"},

      # Docs dependencies
      {:earmark, "~> 0.1", only: :docs},
      {:ex_doc, "~> 0.7.1", only: :docs}
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
