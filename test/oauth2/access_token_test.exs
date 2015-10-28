defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

  alias OAuth2.Client
  alias OAuth2.Response
  alias OAuth2.AccessToken
  alias OAuth2.Strategy.AuthCode

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    token  = build_token(client)
    {:ok, client: client, server: server, token: token}
  end

  test "new from binary token", %{client: client} do
    token = AccessToken.new("abc123", client)
    assert token.access_token == "abc123"
  end

  test "new with 'expires' param", %{client: client} do
    response = Response.new(200, [{"Content-Type", "text/plain"}], "access_token=abc123&expires=123")
    token = AccessToken.new(response.body, client)
    assert token.client.strategy == AuthCode
    assert token.access_token == "abc123"
    assert token.expires_at == 123
    assert token.token_type == "Bearer"
    assert token.other_params == %{"expires" => "123"}
  end

  test "get success", %{client: client, server: server, token: token} do
    Bypass.expect server, fn conn ->
      assert conn.request_path == "/api/success"
      assert get_req_header(conn, "authorization") == ["Bearer #{token.access_token}"]
      assert get_req_header(conn, "accept") == ["application/json"]

      send_resp(conn, 200, ~s({"data": "success!"}))
    end

    {:ok, result} = AccessToken.get(token, "/api/success")
    assert result.status_code == 200
    assert result.body["data"] == "success!"
  end

  test "get error", %{client: client, server: server, token: token} do
    Bypass.expect server, fn conn ->
      assert conn.request_path == "/api/error"
      assert get_req_header(conn, "authorization") == ["Bearer #{token.access_token}"]
      assert get_req_header(conn, "accept") == ["application/json"]

      send_resp(conn, 400, ~s({"data": "oh noes!"}))
    end

    {:ok, result} = AccessToken.get(token, "/api/error")
    assert result.status_code == 400
    assert result.body["data"] == "oh noes!"
  end

  test "get returning 401 with no content-type", %{client: client, server: server, token: token} do
    Bypass.expect server, fn conn ->
      assert conn.request_path == "/api/user"
      assert get_req_header(conn, "authorization") == ["Bearer #{token.access_token}"]

      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(401, " ")
    end

    {:ok, result} = AccessToken.get(token, "/api/user")
    assert result.status_code == 401
    assert result.body == " "
  end

  test "connection error", %{server: server, token: token} do
    Bypass.down(server)

    assert_raise OAuth2.Error, ":econnrefused", fn ->
      AccessToken.get!(token, "/api/error")
    end

    Bypass.up(server)
  end

  test "expires?" do
    assert AccessToken.expires?(%AccessToken{expires_at: 0})
    refute AccessToken.expires?(%AccessToken{expires_at: nil})
  end

  test "expired?" do
    assert AccessToken.expired?(%AccessToken{expires_at: 0})
    refute AccessToken.expired?(%AccessToken{expires_at: nil})
  end

  test "expires_in" do
    assert AccessToken.expires_at(nil) == nil
    assert AccessToken.expires_at(3600) == OAuth2.Util.unix_now + 3600
  end
end
