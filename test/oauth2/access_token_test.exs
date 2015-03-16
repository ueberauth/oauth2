defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true

  alias OAuth2.Response
  alias OAuth2.AccessToken
  alias OAuth2.Strategy.AuthCode

  test "new with 'expires' param" do
    response = Response.new(200, [{"Content-Type", "text/plain"}], "access_token=abc123&expires=123")
    token = AccessToken.new(response.body, %AuthCode{})
    assert token.strategy == %AuthCode{}
    assert token.access_token == "abc123"
    assert token.expires_at == 123
    assert token.token_type == "Bearer"
    assert token.other_params == %{"expires" => "123"}
  end

  test "expires?" do
    assert AccessToken.expires?(%AccessToken{expires_at: 0})
    refute AccessToken.expires?(%AccessToken{expires_at: nil})
  end

  test "expired?" do
    assert AccessToken.expired?(%AccessToken{expires_at: 0})
    refute AccessToken.expired?(%AccessToken{expires_at: nil})
  end

  test "expires_in" do
    assert AccessToken.expires_at(nil) == nil
    assert AccessToken.expires_at(3600) == OAuth2.Util.unix_now + 3600
  end

  test "new" do
    token = AccessToken.new(%{"access_token" => "1234", "expires_in" => 5179052}, %AccessToken{})
    assert AccessToken.expires?(token)

    token = AccessToken.new("access_token=CAAUHkorLHpABAAsErGOrDUZCWt0wjII0k20HyIAliLn9o9WnUMCqXWzocLf91uC6Ml4Mm1ZCemvQ71aaPY8HWciZBLrkpIjQvXtEScKYRAjFQQY8QRwK0ZBkNqIUBPhdZC5ZAGM1LKnmUVOKcIFpdLpPENpKHXMFa2CTfb4CAjR3idqxgr0a04UvTAsnkagcUZD&expires=5168688", %AccessToken{})
    assert AccessToken.expires?(token)
  end
end
