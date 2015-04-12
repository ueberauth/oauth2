defmodule OAuth2.ClientTest do
  use ExUnit.Case, async: true

  @opts [site: "http://localhost", redirect_uri: "http://localhost/auth/callback"]

  test "authorize_url" do
    client = OAuth2.new(@opts)
    {_client, url} = OAuth2.Client.authorize_url(client)
    assert url == "http://localhost/oauth/authorize?client_id=&redirect_uri=http%3A%2F%2Flocalhost%2Fauth%2Fcallback&response_type=code"
  end
end
