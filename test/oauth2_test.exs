defmodule OAuth2Test do
  use ExUnit.Case

  @opts [site: "http://localhost", redirect_uri: "http://localhost/auth/callback"]
  test "`new` delegates to `OAuth2.Client`" do
    client = OAuth2.new(@opts)
    assert client.strategy == OAuth2.Strategy.AuthCode
  end
end
