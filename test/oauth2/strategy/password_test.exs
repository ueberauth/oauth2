defmodule OAuth2.Strategy.PasswordTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.Password
  test "new" do
    opts = %{
      client_id: "client_id",
      client_secret: "secret",
      site: "https://auth.example.com"
    }
    client = Password.new(opts)
    assert client.client_id     == "client_id"
    assert client.client_secret == "secret"
    assert client.site          == "https://auth.example.com"
    assert client.authorize_url == "/oauth/authorize"
    assert client.token_url     == "/oauth/token"
  end
end
