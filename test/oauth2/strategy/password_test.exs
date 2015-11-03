defmodule OAuth2.Strategy.PasswordTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.Password
  import OAuth2.Client
  import OAuth2.TestHelpers

  setup do
    client = build_client(strategy: Password, site: "http://example.com")
    {:ok, client: client}
  end

  test "authorize_url", %{client: client} do
    assert_raise OAuth2.Error, ~r/This strategy does not implement/, fn ->
      authorize_url(client)
    end
  end

  test "get_token when username and password given in params", %{client: client} do
    client = Password.get_token(client, [username: "scrogson", password: "password"], [])
    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
    assert client.params["grant_type"] == "password"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
  end

  test "get_token when username and password updated via put_param", %{client: client} do
    client =
      client
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([], [])

    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
  end

  test "get_token when username and password are not provided", %{client: client} do
    assert_raise OAuth2.Error, ~r/Missing required/, fn ->
      Password.get_token(client, [], [])
    end
  end
end
