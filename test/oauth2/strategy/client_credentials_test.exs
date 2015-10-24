defmodule OAuth2.Strategy.ClientCredentialsTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.ClientCredentials
  import OAuth2.Client
  import OAuth2.TestHelpers

  @client build_client(strategy: ClientCredentials)

  test "new" do
    client = @client
    assert client.client_id     == "client_id"
    assert client.client_secret == "client_secret"
    assert client.site          == "http://localhost:4999"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
    assert client.redirect_uri  == "http://localhost:4998/auth/callback"
  end

  test "authorize_url" do
    assert_raise RuntimeError, "Not implemented.", fn ->
      authorize_url(@client)
    end
  end

  test "get_token: auth_scheme defaults to 'auth_header'" do
    client = @client
    client = ClientCredentials.get_token(client, [], [])
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
    assert client.headers == [{"Authorization", "Basic #{base64}"}]
    assert client.params["grant_type"] == "client_credentials"
  end

  test "get_token: with auth_scheme set to 'request_body'" do
    client = @client
    client = ClientCredentials.get_token(client, [auth_scheme: "request_body"], [])
    assert client.headers == []
    assert client.params["grant_type"] == "client_credentials"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end
end

