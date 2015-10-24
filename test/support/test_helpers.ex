defmodule OAuth2.TestHelpers do

  def call(mod, conn) do
    mod.call(conn, [])
  end

  def build_client(opts \\ []) do
    default_client_opts
    |> Keyword.merge(opts)
    |> OAuth2.Client.new()
  end

  def build_token(opts \\ [], %OAuth2.Client{} = client) do
    default_token_opts
    |> Keyword.merge(opts)
    |> stringify_keys()
    |> OAuth2.AccessToken.new(client)
  end

  defp get_config(key) do
    case Application.get_env(:oauth2, key) do
      {:system, val} -> System.get_env(val)
      val -> val
    end
  end

  defp default_client_opts do
    [client_id: get_config(:client_id),
     client_secret: get_config(:client_secret),
     site: get_config(:site),
     redirect_uri: get_config(:redirect_uri)]
  end

  defp default_token_opts do
    [access_token: "abcdefgh",
     expires_at: OAuth2.Util.unix_now + 600,
     token_type: "Bearer"]
  end

  defp stringify_keys(dict) do
    dict
    |> Enum.map(fn {k,v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
