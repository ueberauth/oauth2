defmodule OAuth2.Strategy.AuthCodeTest do

  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

  alias OAuth2.Strategy.AuthCode

  test "new" do
    conn = call(ConsumerRouter, conn(:get, "/"))
    client = conn.private.oauth2_client
    assert client.client_id     == "client_id"
    assert client.client_secret == "client_secret"
    assert client.site          == "http://localhost:4999"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
    assert client.token_method  == :post
    assert client.params        == %{}
    assert client.headers       == []
  end

  test "authorize_url" do
    conn = call(ConsumerRouter, conn(:get, "/auth"))
    [location] = get_resp_header conn, "location"
    conn = call(ProviderRouter, conn(:get, location))
    assert conn.status == 302

    [location] = get_resp_header conn, "location"
    conn = call(ConsumerRouter, conn(:get, location))
    assert conn.params["code"] == "1234"

    assert_receive %OAuth2.AccessToken{access_token: "abc123", token_type: "Bearer"}
  end

  test "get_token returns new client with needed params and headers for auth code strategy" do
    assert AuthCode.get_token(build_client(), [code: "cdd"], []).params == %{
      "client_id" => "client_id",
      "client_secret" => "client_secret",
      "code" => "cdd",
      "grant_type" => "authorization_code",
      "redirect_uri" => "http://localhost:4998/auth/callback"
    }
  end
  
  test "get_token throws and error if there is no 'code' param" do
    assert_raise RuntimeError, "Missing required key `code` for `OAuth2.Strategy.AuthCode`", fn ->
      AuthCode.get_token(build_client(), [], [])
    end
  end
end
