defmodule OAuth2.TestHelpers do

  def bypass_server(%Bypass{port: port}) do
    "http://localhost:#{port}"
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
    Application.get_env(:oauth2, key)
  end

  defp default_client_opts do
    [client_id: get_config(:client_id),
     client_secret: get_config(:client_secret),
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
