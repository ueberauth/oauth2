defmodule OAuth2.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :oauth2,
      name: "OAuth2",
      version: @version,
      elixir: "~> 1.2",
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        docs: :dev
      ]
    ]
  end

  def application do
    [applications: [:logger, :hackney]]
  end

  defp deps do
    [
      {:hackney, "~> 1.13"},

      # Test dependencies
      {:jason, "~> 1.0", only: [:dev, :test]},
      {:bypass, "~> 0.9", only: :test},
      {:plug_cowboy, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.9", only: :test},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},

      # Docs dependencies
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp description do
    "An Elixir OAuth 2.0 Client Library"
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/scrogson/oauth2"
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Sonny Scroggin"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/scrogson/oauth2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
