defmodule OAuth2.Strategy.ClientCredentialsTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.ClientCredentials
  import OAuth2.Client

  @opts [
    strategy: ClientCredentials,
    client_id: "client_id",
    client_secret: "secret",
    site: "https://auth.example.com",
    redirect_uri: "http://localhost/auth/callback"
  ]

  test "new" do
    client = OAuth2.new(@opts)
    assert client.client_id     == "client_id"
    assert client.client_secret == "secret"
    assert client.site          == "https://auth.example.com"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
    assert client.redirect_uri  == "http://localhost/auth/callback"
  end

  test "authorize_url" do
    assert_raise RuntimeError, "Not implemented.", fn ->
      OAuth2.new(@opts) |> authorize_url()
    end
  end

  test "get_token: auth_scheme defaults to 'auth_header'" do
    client = OAuth2.new(@opts)
    client = ClientCredentials.get_token(client, [], [])
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
    assert client.headers == [{"Authorization", "Basic #{base64}"}]
    assert client.params["grant_type"] == "client_credentials"
  end

  test "get_token: with auth_scheme set to 'request_body'" do
    client = OAuth2.new(@opts)
    client = ClientCredentials.get_token(client, [auth_scheme: "request_body"], [])
    assert client.headers == []
    assert client.params["grant_type"] == "client_credentials"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end
end

