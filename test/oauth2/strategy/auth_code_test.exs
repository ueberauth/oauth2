defmodule OAuth2.Strategy.AuthCodeTest do

  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

  alias OAuth2.Client
  alias OAuth2.AccessToken
  alias OAuth2.Strategy.AuthCode

  setup do
    server = Bypass.open
    client = build_client(strategy: AuthCode, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "authorize_url", %{client: client, server: server} do
    client = AuthCode.authorize_url(client, [])
    assert "http://localhost:#{server.port}" == client.site

    assert client.params["client_id"] == client.client_id
    assert client.params["redirect_uri"] == client.redirect_uri
    assert client.params["response_type"] == "code"
  end

  test "get_token", %{client: client, server: server} do
    code = "abc1234"
    access_token = "access-token-1234"

    Bypass.expect server, fn conn ->
      assert conn.request_path == "/oauth/token"
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]
      assert conn.method == "POST"

      {:ok, body, conn} = read_body(conn)
      body = URI.decode_query(body)

      assert body["grant_type"] == "authorization_code"
      assert body["code"] == code
      assert body["client_id"] == client.client_id
      assert body["client_secret"] == client.client_secret
      assert body["redirect_uri"] == client.redirect_uri

      send_resp(conn, 302, ~s({"access_token":"#{access_token}"}))
    end

    assert {:ok, %AccessToken{} = token} = Client.get_token(client, [code: code])
    assert token.access_token == access_token
  end

  test "get_token throws and error if there is no 'code' param" do
    assert_raise OAuth2.Error, ~r/Missing required key/, fn ->
      AuthCode.get_token(build_client(), [], [])
    end
  end
end
