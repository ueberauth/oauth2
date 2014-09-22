defmodule OAuth2.AccessTokenTest do
  use ExUnit.Case, async: true

  alias OAuth2.AccessToken

  def expired_access_token do
    struct(AccessToken, %{expires_at: 0})
  end

  test "expired" do
    assert AccessToken.expired?(expired_access_token)
  end
end
