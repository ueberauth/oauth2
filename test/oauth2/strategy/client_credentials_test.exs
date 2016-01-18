defmodule OAuth2.Strategy.ClientCredentialsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias OAuth2.Strategy.ClientCredentials
  alias OAuth2.Client
  import OAuth2.TestHelpers

  setup do
    server = Bypass.open
    client = build_client(strategy: ClientCredentials, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "authorize_url", %{client: client} do
    assert_raise OAuth2.Error, ~r/This strategy does not implement/, fn ->
      Client.authorize_url(client)
    end
  end

  test "get_token: auth_scheme defaults to 'auth_header'", %{client: client, server: server} do
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
    token_bearer = "123456=="
    Bypass.expect server, fn conn ->
      assert get_req_header(conn, "Authorization"), "Basic #{base64}"

      send_resp conn, 200, ~s({"access_token": "#{token_bearer}", "token_type": "bearer", "expires_in": "999" })
    end

    token = Client.get_token!(client)
    client = token.client

    # should not include on client response header
    assert List.keyfind(client.headers, "Authorization", 0) == nil
    assert token.access_token == token_bearer
    assert client.params["grant_type"] == "client_credentials"
  end

  test "get_token: with auth_scheme set to 'request_body'", %{client: client} do
    client = ClientCredentials.get_token(client, [auth_scheme: "request_body"], [])
    assert client.headers == []
    assert client.params["grant_type"] == "client_credentials"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end
end
