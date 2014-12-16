defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true

  alias OAuth2.AccessToken

  test "expires?" do
    assert AccessToken.expires?(%AccessToken{expires_in: 0})
    refute AccessToken.expires?(%AccessToken{expires_in: nil})
  end

  test "expired?" do
    assert AccessToken.expired?(%AccessToken{expires_in: 0})
    refute AccessToken.expired?(%AccessToken{expires_in: nil})
  end

  test "expires_in" do
    assert AccessToken.expires_in(nil) == nil
    assert AccessToken.expires_in(3600) == OAuth2.Util.unix_now + 3600
  end
end
