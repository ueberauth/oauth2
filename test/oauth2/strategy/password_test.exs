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
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)

    assert client.params["username"] == "scrogson"
    assert client.params["password"] == "password"
    assert client.params["grant_type"] == "password"

    assert List.keyfind(client.headers, "authorization", 0) ==
             {"authorization", "Basic #{base64}"}
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

  test "get_token: auth_scheme defaults to 'auth_header'", %{client: client} do
    client =
      client
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([], [])

    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)
    assert client.headers == [{"authorization", "Basic #{base64}"}]
    assert client.params["grant_type"] == "password"
    refute client.params["client_id"]
    refute client.params["client_secret"]
    refute client.params["client_assertion_type"]
    refute client.params["client_assertion"]
  end

  test "get_token: with auth_scheme set to 'request_body'", %{client: client} do
    client =
      client
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([auth_scheme: "request_body"], [])

    assert client.headers == []
    assert client.params["grant_type"] == "password"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
    refute client.params["client_assertion_type"]
    refute client.params["client_assertion"]
  end

  test "get_token: with auth_scheme set to 'client_secret_jwt'", %{client: client} do
    client =
      client
      |> put_param(:username, "scrogson")
      |> put_param(:password, "password")
      |> Password.get_token([auth_scheme: "client_secret_jwt"], [])

    assert client.headers == []
    assert client.params["grant_type"] == "password"
    refute client.params["client_id"]
    refute client.params["client_secret"]

    assert client.params["client_assertion_type"] ==
             "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"

    assert client.params["client_assertion"]
  end
end
