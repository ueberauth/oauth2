defmodule OAuth2.ClientTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest OAuth2.Client

  import OAuth2.Client
  import OAuth2.TestHelpers

  alias OAuth2.Client

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    client_with_token = tokenize_client(client)
    async_client = async_client(client)

    {:ok, client: client,
          server: server,
          client_with_token: client_with_token,
          async_client: async_client}
  end

  test "authorize_url!", %{client: client, server: server} do
    uri = URI.parse(authorize_url!(client))
    assert "#{uri.scheme}://#{uri.host}:#{uri.port}" == client.site
    assert uri.port == server.port
    assert uri.path == "/oauth/authorize"

    query = URI.decode_query(uri.query)
    assert query["client_id"] == client.client_id
    assert query["redirect_uri"] == client.redirect_uri
    assert query["response_type"] == "code"
  end

  test "get_token, get_token!", %{client: client, server: server} do
    bypass server, "POST", "/oauth/token", fn conn ->
      assert conn.query_string == ""
      send_resp(conn, 200, ~s({"access_token":"test1234"}))
    end

    assert {:ok, client} = Client.get_token(client, [code: "code1234"], [{"Accept", "application/json"}])
    assert client.token.access_token == "test1234"
    assert %Client{} = Client.get_token!(client, [code: "code1234"], [{"Accept", "application/json"}])
  end

  test "get_token, get_token! when `:token_method` is `:get`", %{client: client, server: server} do
    client = %{client | token_method: :get}

    bypass server, "GET", "/oauth/token", fn conn ->
      refute conn.query_string == ""
      assert conn.query_params["code"] == "code1234"
      assert conn.query_params["redirect_uri"]
      send_resp(conn, 200, ~s({"access_token":"test1234","token_type":"bearer"}))
    end

    assert {:ok, %Client{token: token}} = Client.get_token(client, code: "code1234")
    assert token.access_token == "test1234"
    assert %Client{token: token} = Client.get_token!(client, code: "code1234")
    assert token.access_token == "test1234"
  end

  test "refresh_token and refresh_token! with a POST", %{server: server, client_with_token: client} do
    bypass server, "POST", "/oauth/token", fn conn ->
      assert get_req_header(conn, "authorization") == []
      assert get_req_header(conn, "accept") == ["application/json"]
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s({"access_token":"new-access-token","refresh_token":"new-refresh-token"}))
    end

    {:error, error} = Client.refresh_token(client)
    assert error.reason =~ ~r/token not available/

    assert_raise OAuth2.Error, ~r/token not available/, fn ->
      Client.refresh_token!(client)
    end

    token = client.token
    client = %{client | token: %{token | refresh_token: "abcdefg"}}
    assert {:ok, client} = Client.refresh_token(client, [], [{"accept", "application/json"}])
    assert client.token.access_token == "new-access-token"
    assert client.token.refresh_token == "new-refresh-token"
  end

  test "refresh token when response missing refresh_token", %{server: server, client_with_token: client} do
    bypass server, "POST", "/oauth/token", fn conn ->
      assert get_req_header(conn, "authorization") == []
      assert get_req_header(conn, "accept") == ["application/json"]
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s({"access_token":"new-access-token"}))
    end

    token = client.token
    client = %{client | token: %{token | refresh_token: "old-refresh-token"}}
    assert {:ok, client} = Client.refresh_token(client, [], [{"accept", "application/json"}])
    assert client.token.access_token == "new-access-token"
    assert client.token.refresh_token == "old-refresh-token"
  end


  test "put_param, merge_params", %{client: client} do
    assert Map.size(client.params) == 0

    client = put_param(client, :scope, "user,email")
    assert client.params["scope"] == "user,email"

    client = merge_params(client, scope: "overridden")
    assert client.params["scope"] == "overridden"

    client = put_param(client, "scope", "binary keys work too")
    assert client.params["scope"] == "binary keys work too"
  end

  test "put_header, put_headers", %{client: client} do
    client = put_header(client, "accepts", "application/json")
    assert {"accepts", "application/json"} = List.keyfind(client.headers, "accepts", 0)
    client = put_headers(client, [{"accepts", "application/xml"},{"content-type", "application/xml"}])
    assert {"accepts", "application/xml"} = List.keyfind(client.headers, "accepts", 0)
    assert {"content-type", "application/xml"} = List.keyfind(client.headers, "content-type", 0)
  end

  ## GET

  test "GET", %{server: server, client_with_token: client} do
    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = Client.get(client, "/api/user/1")
    assert result.status_code == 200
    assert result.body["id"] == 1

    result = Client.get!(client, "/api/user/1")
    assert result.status_code == 200
    assert result.body["id"] == 1
  end

  test "GET with async options", %{server: server, async_client: client} do
    body = :binary.copy("a", 8000)

    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      send_resp(conn, 200, body)
    end)

    {:ok, ref} = Client.get(client, "/api/user/1")

    assert_receive {:hackney_response, ^ref, {:status, 200, "OK"}}
    assert_receive {:hackney_response, ^ref, {:headers, headers}}
    assert {_, "8000"} = List.keyfind(headers, "content-length", 0)
    resp_body = stream(ref)
    assert resp_body == body
  end

  defp stream(ref, buffer \\ []) do
    receive do
      {:hackney_response, ^ref, :done} ->
        IO.iodata_to_binary(buffer)
      {:hackney_response, ^ref, binary} ->
        stream(ref, buffer ++ [binary])
    end
  end

  ## POST

  test "POST", %{server: server, client_with_token: client} do
    title = "Totally awesome blog post"

    bypass server, "POST", "/api/posts", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = Client.post(client, "/api/posts", %{title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = Client.post!(client, "/api/posts", %{title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## PUT

  test "PUT", %{server: server, client_with_token: client} do
    title = "Totally awesome blog post!"

    bypass server, "PUT", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = Client.put(client, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = Client.put!(client, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## PATCH

  test "PATCH", %{server: server, client_with_token: client} do
    title = "Totally awesome blog post!"

    bypass server, "PATCH", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end

    {:ok, result} = Client.patch(client, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title

    result = Client.patch!(client, "/api/posts/1", %{id: 1, title: title})
    assert result.status_code == 200
    assert result.body["id"] == 1
    assert result.body["title"] == title
  end

  ## DELETE

  test "DELETE", %{server: server, client_with_token: client} do
    bypass server, "DELETE", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 204, "")
    end

    {:ok, result} = Client.delete(client, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""

    result = Client.delete!(client, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""
  end

  test "params in opts turn into a query string", %{server: server, client_with_token: client} do
    Bypass.expect server, fn conn ->
      assert conn.query_string == "access_token=#{client.token.access_token}"
      send_resp(conn, 200, "")
    end

    assert {:ok, _} = Client.get(client, "/me", [], params: [access_token: client.token.access_token])
  end

  test "get returning 401 with no content-type", %{server: server, client_with_token: client} do
    bypass server, "GET", "/api/user", [token: client.token], fn conn ->
      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(401, " ")
    end

    {:ok, result} = Client.get(client, "/api/user")
    assert result.status_code == 401
    assert result.body == ""
  end

  test "connection error", %{server: server, client_with_token: client} do
    Bypass.down(server)

    assert_raise OAuth2.Error, "Connection refused", fn ->
      Client.get!(client, "/api/error")
    end

    Bypass.up(server)
  end
end
