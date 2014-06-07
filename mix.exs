defmodule Oauth2.Mixfile do
  use Mix.Project

  @description """
  Elixir OAuth2 Client
  """

  def project do
    [
      app: :oauth2,
      version: "0.0.1",
      elixir: ">= 0.13.3",
      deps: deps,
      description: @description,
      package: [
        contributors: ["Sonny Scroggin"],
        licence: "MIT",
        links: [github: "https://github.com/scrogson/oauth2"]
      ]
    ]
  end

  def application do
    [applications: [:httpoison],
     mod: {OAuth2, []}]
  end

  defp deps do
    [
      {:httpoison, github: "edgurgel/httpoison", tag: "0.1.1"},
      {:ex_conf, "0.1.1"}
    ]
  end
end
