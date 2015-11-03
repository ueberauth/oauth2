defmodule OAuth2.ClientTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.Client
  import OAuth2.TestHelpers

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    {:ok, client: client, server: server}
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

    assert {:ok, token} = OAuth2.Client.get_token(client, [code: "code1234"], [{"Accept", "application/json"}])
    assert token.access_token == "test1234"
    assert %OAuth2.AccessToken{} = OAuth2.Client.get_token!(client, [code: "code1234"], [{"Accept", "application/json"}])
  end

  test "get_token, get_token! when `:token_method` is `:get`", %{client: client, server: server} do
    client = %{client | token_method: :get}

    bypass server, "GET", "/oauth/token", fn conn ->
      refute conn.query_string == ""
      assert conn.query_params["code"] == "code1234"
      assert conn.query_params["redirect_uri"]
      assert conn.query_params["client_secret"]
      send_resp(conn, 200, ~s({"access_token":"test1234"}))
    end

    assert {:ok, token} = OAuth2.Client.get_token(client, code: "code1234")
    assert token.access_token == "test1234"
    assert %OAuth2.AccessToken{} = token = OAuth2.Client.get_token!(client, code: "code1234")
    assert token.access_token == "test1234"
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
    client = put_header(client, "Accepts", "application/json")
    assert {"Accepts", "application/json"} = List.keyfind(client.headers, "Accepts", 0)
    client = put_headers(client, [{"Accepts", "application/xml"},{"Content-Type", "application/xml"}])
    assert {"Accepts", "application/xml"} = List.keyfind(client.headers, "Accepts", 0)
    assert {"Content-Type", "application/xml"} = List.keyfind(client.headers, "Content-Type", 0)
  end
end
