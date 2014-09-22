defmodule OAuth2.AccessToken do
  alias OAuth2.Util

  defstruct [
    token: "",
    expires_at: nil,
    refresh_token: "",
    token_type: "Bearer"
  ]

  def expired?(access_token) do
    Util.unix_now > access_token.expires_at
  end
end
