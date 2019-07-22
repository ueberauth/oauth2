defmodule OAuth2.ClientTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest OAuth2.Client

  import ExUnit.CaptureIO
  import OAuth2.Client
  import OAuth2.TestHelpers

  alias OAuth2.Client
  alias OAuth2.Response

  setup do
    server = Bypass.open()
    client = build_client(site: bypass_server(server))
    client_with_token = tokenize_client(client)
    async_client = async_client(client)
    basic_auth = Base.encode64(client.client_id <> ":" <> client.client_secret)

    {:ok,
     basic_auth: basic_auth,
     client: client,
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
    bypass(server, "POST", "/oauth/token", fn conn ->
      assert conn.query_string == ""
      send_resp(conn, 200, ~s({"access_token":"test1234"}))
    end)

    assert {:ok, client} =
             Client.get_token(client, [code: "code1234"], [{"accept", "application/json"}])

    assert client.token.access_token == "test1234"

    assert %Client{} =
             Client.get_token!(client, [code: "code1234"], [{"accept", "application/json"}])
  end

  test "get_token, get_token! when `:token_method` is `:get`", %{client: client, server: server} do
    client = %{client | token_method: :get}

    bypass(server, "GET", "/oauth/token", fn conn ->
      refute conn.query_string == ""
      assert conn.query_params["code"] == "code1234"
      assert conn.query_params["redirect_uri"]
      send_resp(conn, 200, ~s({"access_token":"test1234","token_type":"bearer"}))
    end)

    assert {:ok, %Client{token: token}} = Client.get_token(client, code: "code1234")
    assert token.access_token == "test1234"
    assert %Client{token: token} = Client.get_token!(client, code: "code1234")
    assert token.access_token == "test1234"
  end

  test "get_token, get_token! when response error", %{client: client, server: server} do
    code = [code: "code1234"]
    headers = [{"accept", "application/json"}]

    bypass(server, "POST", "/oauth/token", fn conn ->
      assert conn.query_string == ""
      send_resp(conn, 500, ~s({"error":"missing_client_id"}))
    end)

    assert {:error, error} = Client.get_token(client, code, headers)
    assert %Response{body: body, status_code: 500} = error
    assert body == %{"error" => "missing_client_id"}

    assert_raise OAuth2.Error, ~r/Body/, fn ->
      Client.get_token!(client, code, headers)
    end
  end

  test "refresh_token and refresh_token! with a POST", %{
    basic_auth: base64,
    server: server,
    client_with_token: client
  } do
    bypass(server, "POST", "/oauth/token", fn conn ->
      assert get_req_header(conn, "authorization") == ["Basic #{base64}"]
      assert get_req_header(conn, "accept") == ["application/json"]
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(
        200,
        ~s({"access_token":"new-access-token","refresh_token":"new-refresh-token"})
      )
    end)

    {:error, error} = Client.refresh_token(client)
    assert error.reason =~ ~r/token not available/

    assert_raise OAuth2.Error, ~r/token not available/, fn ->
      Client.refresh_token!(client)
    end

    token = client.token
    client = %{client | token: %{token | refresh_token: "abcdefg"}}
    assert {:ok, client_a} = Client.refresh_token(client, [], [{"accept", "application/json"}])
    assert client_a.token.access_token == "new-access-token"
    assert client_a.token.refresh_token == "new-refresh-token"

    assert client_b = Client.refresh_token!(client, [], [{"accept", "application/json"}])
    assert client_b.token.access_token == "new-access-token"
    assert client_b.token.refresh_token == "new-refresh-token"
  end

  test "refresh token when response missing refresh_token", %{
    basic_auth: base64,
    server: server,
    client_with_token: client
  } do
    bypass(server, "POST", "/oauth/token", fn conn ->
      assert get_req_header(conn, "authorization") == ["Basic #{base64}"]
      assert get_req_header(conn, "accept") == ["application/json"]
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s({"access_token":"new-access-token"}))
    end)

    token = client.token
    client = %{client | token: %{token | refresh_token: "old-refresh-token"}}
    assert {:ok, client} = Client.refresh_token(client, [], [{"accept", "application/json"}])
    assert client.token.access_token == "new-access-token"
    assert client.token.refresh_token == "old-refresh-token"
  end

  test "put_param, merge_params", %{client: client} do
    assert map_size(client.params) == 0

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

    client =
      put_headers(client, [{"accepts", "application/xml"}, {"content-type", "application/xml"}])

    assert {"accepts", "application/xml"} = List.keyfind(client.headers, "accepts", 0)
    assert {"content-type", "application/xml"} = List.keyfind(client.headers, "content-type", 0)
  end

  test "basic_auth", %{client: client} do
    %OAuth2.Client{client_id: id, client_secret: secret} = client
    client = basic_auth(client)

    assert {"authorization", value} = List.keyfind(client.headers, "authorization", 0)
    assert value == "Basic " <> Base.encode64(id <> ":" <> secret)
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

  test "GET with with_body: true", %{server: server, client_with_token: client} do
    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = Client.get(client, "/api/user/1", [], with_body: true)
    assert result.status_code == 200
    assert result.body["id"] == 1

    result = Client.get!(client, "/api/user/1")
    assert result.status_code == 200
    assert result.body["id"] == 1
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

    bypass(server, "POST", "/api/posts", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end)

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

    bypass(server, "PUT", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end)

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

    bypass(server, "PATCH", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1, title: title})
    end)

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
    bypass(server, "DELETE", "/api/posts/1", [token: client.token], fn conn ->
      json(conn, 204, "")
    end)

    {:ok, result} = Client.delete(client, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""

    result = Client.delete!(client, "/api/posts/1")
    assert result.status_code == 204
    assert result.body == ""
  end

  test "params in opts turn into a query string", %{server: server, client_with_token: client} do
    Bypass.expect(server, fn conn ->
      assert conn.query_string == "access_token=#{client.token.access_token}"
      send_resp(conn, 200, "")
    end)

    assert {:ok, _} =
             Client.get(client, "/me", [], params: [access_token: client.token.access_token])
  end

  test "follow redirects", %{server: server, client_with_token: client} do
    Bypass.expect(server, fn conn ->
      case conn.path_info do
        ["old"] ->
          conn
          |> put_resp_header("location", "http://localhost:#{server.port}/new")
          |> send_resp(302, "")

        ["new"] ->
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(200, "ok")
      end
    end)

    assert {:ok, %{body: "ok", status_code: 200}} =
             Client.get(client, "/old", [],
               params: [access_token: client.token.access_token],
               follow_redirect: true
             )
  end

  test "get returning 401 with no content", %{server: server, client_with_token: client} do
    bypass(server, "GET", "/api/user", [token: client.token], fn conn ->
      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(401, " ")
    end)

    {:error, result} = Client.get(client, "/api/user")
    assert result.status_code == 401
    assert result.body == ""
  end

  test "bang functions raise errors", %{server: server, client: client} do
    Bypass.expect(server, fn conn ->
      json(conn, 400, %{error: "error"})
    end)

    assert_raise OAuth2.Error, ~r/Server responded with status: 400/, fn ->
      Client.get!(client, "/api/error")
    end
  end

  test "connection error", %{server: server, client_with_token: client} do
    Bypass.down(server)

    assert_raise OAuth2.Error, "Connection refused", fn ->
      Client.get!(client, "/api/error")
    end

    Bypass.up(server)
  end

  test "does not log sensitive values", %{client: client} do
    client = %Client{client_id: client.client_id, client_secret: "abc123", token: "def456"}
    captured_string = capture_io(fn -> IO.inspect(client) end)
    refute captured_string =~ "abc123"
    refute captured_string =~ "def456"
    assert captured_string =~ client.client_id
  end
end
