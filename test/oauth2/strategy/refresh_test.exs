defmodule OAuth2.Strategy.RefreshTest do
  use ExUnit.Case, async: true

  import OAuth2.TestHelpers

  alias OAuth2.Strategy.Refresh

  test "authorize_url" do
    assert_raise OAuth2.Error, ~r/This strategy does not implement/, fn ->
      Refresh.authorize_url(build_client(), [])
    end
  end

  test "get_token" do
    client = build_client()
    client = Refresh.get_token(client, [refresh_token: "refresh-token"], [])
    base64 = Base.encode64(client.client_id <> ":" <> client.client_secret)

    assert client.params["grant_type"] == "refresh_token"
    assert client.params["refresh_token"] == "refresh-token"

    assert List.keyfind(client.headers, "authorization", 0) ==
             {"authorization", "Basic #{base64}"}
  end

  test "get_token throws and error if there is no 'refresh_token' param" do
    assert_raise OAuth2.Error, ~r/Missing required key `refresh_token`/, fn ->
      Refresh.get_token(build_client(), [], [])
    end
  end

  test "get_token: with auth_method set to 'request_body'" do
    client = build_client()

    client =
      Refresh.get_token(client, [refresh_token: "refresh-token", auth_method: "request_body"], [])

    assert client.headers == []
    assert client.params["grant_type"] == "refresh_token"
    assert client.params["client_id"] == client.client_id
    assert client.params["client_secret"] == client.client_secret
    refute client.params["client_assertion_type"]
    refute client.params["client_assertion"]
  end

  test "get_token: with auth_method set to 'client_secret_jwt'" do
    client = build_client()

    client =
      Refresh.get_token(
        client,
        [refresh_token: "refresh-token", auth_method: "client_secret_jwt"],
        []
      )

    assert client.headers == []
    assert client.params["grant_type"] == "refresh_token"
    refute client.params["client_id"]
    refute client.params["client_secret"]

    assert client.params["client_assertion_type"] ==
             "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"

    assert client.params["client_assertion"]
  end
end
