defmodule OAuth2.Client do
  use HTTPoison.Base

  alias OAuth2.Client

  defstruct grant_type: nil, auth_url: nil, access_token: nil,
            refresh_token: nil, id: nil, secret: nil, scope: nil

  def get_access_token(type, url, id, secret, scope \\ :undefined) do
    %Client{grant_type: type, auth_url: url, id: id, secret: secret, scope: scope}
    |> do_get_access_token
  end
  defp do_get_access_token(%Client{grant_type: "password"} = client) do
    payload  = request_payload(client)
    response = post(client.auth_url, payload)
    IO.inspect response
  end
  defp do_get_access_token(%Client{grant_type: "client_credentials"} = client) do
    payload  = request_payload(client)
    response = post(client.auth_url, payload)
    IO.inspect response
  end

  defp request_payload(%Client{grant_type: "password", scope: :undefined} = client) do
    [ grant_type: client.grant_type,
      username:   client.username,
      password:   client.password ]
  end
  defp request_payload(%Client{grant_type: "password"}) do
    [ grant_type: client.grant_type,
      username:   client.username,
      password:   client.password,
      scope:      client.scope ]
  end
  defp request_payload(%Client{grant_type: "client_credentials"} = client) do
    [ grant_type: client.grant_type,
      username:   client.username,
      password:   client.password ]
  end
end
