defmodule OAuth2.Strategy.AuthCodeTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.AuthCode

  test "new" do
    opts = %{
      client_id: "client_id",
      client_secret: "secret",
      site: "https://auth.example.com"
    }
    client = AuthCode.new(opts)
    assert client.__struct__    == OAuth2.Client
    assert client.strategy      == AuthCode
    assert client.client_id     == "client_id"
    assert client.client_secret == "secret"
    assert client.site          == "https://auth.example.com"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
    assert client.redirect_uri  == nil
  end
end
