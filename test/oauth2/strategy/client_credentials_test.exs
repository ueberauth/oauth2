defmodule OAuth2.Strategy.ClientCredentialsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias OAuth2.Client
  alias OAuth2.Strategy.ClientCredentials
  import OAuth2.TestHelpers

  setup do
    server = Bypass.open()
    client = build_client(strategy: ClientCredentials, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "authorize_url", %{client: client} do
    assert_raise OAuth2.Error, ~r/This strategy does not implement/, fn ->
      Client.authorize_url(client)
    end
  end

  test "get_token: auth_scheme defaults to 'auth_header'", %{client: client} do
    client = ClientCredentials.get_token(client, [], [])
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
    assert client.headers == [{"authorization", "Basic #{base64}"}]
    assert client.params["grant_type"] == "client_credentials"
    refute client.params["client_id"]
    refute client.params["client_secret"]
    refute client.params["client_assertion_type"]
    refute client.params["client_assertion"]
  end

  test "get_token: Duplicated auth_header ", %{client: client, server: server} do
    Bypass.expect(server, fn conn ->
      base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
      assert get_req_header(conn, "authorization") == ["Basic #{base64}"]

      send_resp(
        conn,
        200,
        ~s({"access_token": "123456==", "token_type": "bearer", "expires_in": "999" })
      )
    end)

    client = Client.get_token!(client)

    assert client.token.access_token == "123456=="
    assert List.keyfind(client.headers, "authorization", 0) == nil
  end

  test "get_token: with auth_scheme set to 'request_body'", %{client: client} do
    client = ClientCredentials.get_token(client, [auth_scheme: "request_body"], [])
    assert client.headers == []
    assert client.params["grant_type"] == "client_credentials"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
    refute client.params["client_assertion_type"]
    refute client.params["client_assertion"]
  end

  test "get_token: with auth_scheme set to 'client_secret_jwt'", %{client: client} do
    client = ClientCredentials.get_token(client, [auth_scheme: "client_secret_jwt"], [])
    assert client.headers == []
    assert client.params["grant_type"] == "client_credentials"
    refute client.params["client_id"]
    refute client.params["client_secret"]

    assert client.params["client_assertion_type"] ==
             "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"

    assert client.params["client_assertion"]
  end
end
