defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

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

  ## GET

  test "GET", %{server: server, token: token} do
    bypass(server, "GET", "/api/user/1", [token: token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = AccessToken.get(token, "/api/user/1")
    assert result.status_code == 200
    assert result.body["id"] == 1

    result = AccessToken.get!(token, "/api/user/1")
    assert result.status_code == 200
    assert result.body["id"] == 1
  end

  ## POST

  test "POST", %{server: server, token: token} do
    title = "Totally awesome blog post"

    bypass server, "POST", "/api/posts", [token: token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = AccessToken.post(token, "/api/posts", %{title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = AccessToken.post!(token, "/api/posts", %{title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## PUT

  test "PUT", %{server: server, token: token} do
    title = "Totally awesome blog post!"

    bypass server, "PUT", "/api/posts/1", [token: token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = AccessToken.put(token, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = AccessToken.put!(token, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## PATCH

  test "PATCH", %{server: server, token: token} do
    title = "Totally awesome blog post!"

    bypass server, "PATCH", "/api/posts/1", [token: token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = AccessToken.patch(token, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = AccessToken.patch!(token, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## DELETE

  test "DELETE", %{server: server, token: token} do
    bypass server, "DELETE", "/api/posts/1", [token: token], fn conn ->
      json(conn, 204, "")
    end

    {:ok, result} = AccessToken.delete(token, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""

    result = AccessToken.delete!(token, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""
  end

  test "params in opts turn into a query string", %{server: server, token: token} do
    Bypass.expect server, fn conn ->
      assert conn.query_string == "access_token=#{token.access_token}"
      send_resp(conn, 200, "")
    end

    assert {:ok, _} = AccessToken.get(token, "/me", [], params: [access_token: token.access_token])
  end

  test "get returning 401 with no content-type", %{server: server, token: token} do
    bypass server, "GET", "/api/user", [token: token], fn conn ->
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

    assert_raise OAuth2.Error, "Connection refused", fn ->
      AccessToken.get!(token, "/api/error")
    end

    Bypass.up(server)
  end

  test "refresh and refresh! with a POST", %{server: server, token: token} do
    bypass server, "POST", "/oauth/token", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s({"access_token":"new-access-token","refresh_token":"new-refresh-token"}))
    end

    {:error, error} = AccessToken.refresh(token)
    assert error.reason =~ ~r/token not available/

    assert_raise OAuth2.Error, ~r/token not available/, fn ->
      AccessToken.refresh!(token)
    end

    token = %{token | refresh_token: "abcdefg"}
    assert {:ok, token} = AccessToken.refresh(token, [], [{"accept", "application/json"}])
    assert token.access_token == "new-access-token"
    assert token.refresh_token == "new-refresh-token"
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
