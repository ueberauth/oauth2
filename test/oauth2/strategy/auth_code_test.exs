defmodule OAuth2.Strategy.AuthCodeTest do
  use ExUnit.Case, async: true

  alias OAuth2.Strategy.AuthCode

  test "authorize_url" do
    opts = [
      client_id: "client_id", client_secret: "secret", site: "https://auth.example.com"
    ]
    client = AuthCode.new(opts)
    assert AuthCode.authorize_url(client) == %{client_id: "client_id", response_type: "code"}
  end
end
