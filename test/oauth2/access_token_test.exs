defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true

  alias OAuth2.{AccessToken, Response}

  test "new from binary token" do
    token = AccessToken.new("abc123")
    assert token.access_token == "abc123"
  end

  test "new with 'expires' param" do
    response = Response.new(200, [{"content-type", "text/plain"}], "access_token=abc123&expires=123")
    token = AccessToken.new(response.body)
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
end
