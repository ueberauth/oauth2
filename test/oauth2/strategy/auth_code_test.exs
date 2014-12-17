defmodule OAuth2.Strategy.AuthCodeTest do

  use ExUnit.Case, async: true
  use Plug.Test

  test "new" do
    conn = call(Client, conn(:get, "/"))
    strategy = conn.private.oauth2_strategy
    assert strategy.client_id     == "client_id"
    assert strategy.client_secret == "secret"
    assert strategy.site          == "http://localhost:4000"
    assert strategy.authorize_url == "/oauth/authorize"
    assert strategy.token_url     == "/oauth/token"
    assert strategy.token_method  == :post
    assert strategy.params        == %{}
    assert strategy.headers       == %{}
  end

  test "authorize_url" do
    Plug.Adapters.Cowboy.http Provider, []
    Plug.Adapters.Cowboy.http Client, [], port: 4001

    conn = call(Client, conn(:get, "/auth"))
    [location] = get_resp_header conn, "Location"
    conn = call(Provider, conn(:get, location))
    assert conn.status == 302

    [location] = get_resp_header conn, "Location"
    conn = call(Client, conn(:get, location))
    assert conn.params["code"] == "1234"

    assert_receive %OAuth2.AccessToken{access_token: "abc123", token_type: "Bearer"}
  end

  defp call(mod, conn) do
    mod.call(conn, [])
  end
end
