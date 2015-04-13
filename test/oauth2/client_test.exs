defmodule OAuth2.ClientTest do
  use ExUnit.Case, async: true

  import OAuth2.Client

  @opts [site: "http://localhost", redirect_uri: "http://localhost/auth/callback"]

  test "authorize_url" do
    client = OAuth2.new(@opts)
  {_client, url} = authorize_url(client)
    assert url == "http://localhost/oauth/authorize?client_id=&redirect_uri=http%3A%2F%2Flocalhost%2Fauth%2Fcallback&response_type=code"
  end

  test "put_param, merge_params" do
    client = OAuth2.new(@opts)
    assert Map.size(client.params) == 0

    client = put_param(client, :scope, "user,email")
    assert client.params["scope"] == "user,email"

    client = merge_params(client, scope: "overridden")
    assert client.params["scope"] == "overridden"
  end

  test "put_header, put_headers" do
    client = OAuth2.new(@opts)
    client = put_header(client, "Accepts", "application/json")
    assert {"Accepts", "application/json"} = List.keyfind(client.headers, "Accepts", 0)
    client = put_headers(client, [{"Accepts", "application/xml"},{"Content-Type", "application/xml"}])
    assert {"Accepts", "application/xml"} = List.keyfind(client.headers, "Accepts", 0)
    assert {"Content-Type", "application/xml"} = List.keyfind(client.headers, "Content-Type", 0)
  end
end

