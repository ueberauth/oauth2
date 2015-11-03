defmodule OAuth2.Mixfile do
  use Mix.Project

  @version "0.5.0"

  def project do
    [app: :oauth2,
     name: "OAuth2",
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     package: package,
     description: description,
     docs: docs,
     elixirc_paths: elixirc_paths(Mix.env),
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:httpoison, :poison, :mimetype_parser]]
  end

  defp deps do
    [{:httpoison, "~> 0.7"},
     {:poison, "~> 1.3"},
     {:mimetype_parser, "~> 0.1"},

     # Test dependencies
     {:bypass, "~> 0.1", only: :test},
     {:excoveralls, "~> 0.3", only: :test},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :docs},
     {:ex_doc, "~> 0.10", only: :docs}]
  end

  defp description do
    "An Elixir OAuth 2.0 Client Library"
  end

  defp docs do
    [extras: ["README.md"],
     main: "extra-readme",
     source_ref: "v#{@version}",
     source_url: "https://github.com/scrogson/oauth2"]
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Sonny Scroggin"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/scrogson/oauth2"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
