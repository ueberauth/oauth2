defmodule OAuth2.Strategy.PasswordTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.Password
  import OAuth2.Client
  import OAuth2.TestHelpers

  @client build_client(strategy: Password)

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

  test "get_token when username and password given in params" do
    client = @client
    client = Password.get_token(client, [username: "scrogson", password: "password"], [])
    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
    assert client.params["grant_type"] == "password"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end

  test "get_token when username and password updated via put_param" do
    client =
      @client
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([], [])

    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
  end

  test "get_token when username and password are not provided" do
    assert_raise RuntimeError, "Missing required keys `username` and `password` for OAuth2.Strategy.Password", fn ->
      Password.get_token(@client, [], [])
    end
  end
end

