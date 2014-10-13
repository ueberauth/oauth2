defmodule OAuth2.Strategy.AuthCodeTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  @redirect_uri "https://example.com/auth/callback"
  @encoded_redirect_uri URI.encode_query(%{redirect_uri: @redirect_uri})

  @opts %{
    client_id: "client_id",
    client_secret: "secret",
    site: "https://auth.example.com",
  }

  test "new" do
    strategy = AuthCode.new(@opts)
    assert strategy.client_id     == "client_id"
    assert strategy.client_secret == "secret"
    assert strategy.site          == "https://auth.example.com"
    assert strategy.authorize_url == "/oauth/authorize"
    assert strategy.token_url     == "/oauth/token"
    assert strategy.token_method  == :post
    assert strategy.params        == %{}
    assert strategy.headers       == []
  end

  test "authorize_url" do
    strategy = AuthCode.new(@opts)
    params = %{redirect_uri: @redirect_uri}
    url = OAuth2.authorize_url(strategy, params)
    assert url == "https://auth.example.com/oauth/authorize?client_id=client_id&#{@encoded_redirect_uri}&response_type=code"
  end

  test "token_url" do
    strategy = AuthCode.new(@opts)
    params = %{redirect_uri: @redirect_uri, code: "abc1234"}
    url = OAuth2.token_url(strategy, params)
    assert url == "https://auth.example.com/oauth/token?client_id=client_id&client_secret=secret&code=abc1234&grant_type=authorization_code&#{@encoded_redirect_uri}"
  end
end
