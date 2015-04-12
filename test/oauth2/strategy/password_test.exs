defmodule OAuth2.Strategy.PasswordTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.Password
  import OAuth2.Client

  @opts [
    strategy: Password,
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
      OAuth2.new(@opts) |> OAuth2.authorize_url()
    end
  end

  test "get_token when username and password given in params" do
    client = OAuth2.new(@opts)
    client = Password.get_token(client, [username: "scrogson", password: "password"], [])
    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
    assert client.params["grant_type"] == "password"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end

  test "get_token when username and password updated via put_param" do
    client =
      OAuth2.new(@opts)
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([], [])

    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
  end

  test "get_token when username and password are not provided" do
    assert_raise RuntimeError, "Missing required keys `username` and `password` for OAuth2.Strategy.Password", fn ->
      OAuth2.new(@opts) |> Password.get_token([], [])
    end
  end
end

