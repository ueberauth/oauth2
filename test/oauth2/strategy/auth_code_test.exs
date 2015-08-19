defmodule OAuth2.Strategy.AuthCodeTest do

  use ExUnit.Case, async: true
  use Plug.Test

  test "new" do
    conn = call(Client, conn(:get, "/"))
    client = conn.private.oauth2_client
    assert client.client_id     == "client_id"
    assert client.client_secret == "secret"
    assert client.site          == "http://localhost:4999"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
    assert client.token_method  == :post
    assert client.params        == %{}
    assert client.headers       == []
  end

  test "authorize_url" do
    Plug.Adapters.Cowboy.http Provider, [], port: 4999
    Plug.Adapters.Cowboy.http Client, [], port: 4998

    conn = call(Client, conn(:get, "/auth"))
    [location] = get_resp_header conn, "location"
    conn = call(Provider, conn(:get, location))
    assert conn.status == 302

    [location] = get_resp_header conn, "location"
    conn = call(Client, conn(:get, location))
    assert conn.params["code"] == "1234"

    assert_receive %OAuth2.AccessToken{access_token: "abc123", token_type: "Bearer"}
  end

  defp call(mod, conn) do
    mod.call(conn, [])
  end
end
