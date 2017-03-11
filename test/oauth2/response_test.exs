defmodule OAuth2.ResponseTest do
  use ExUnit.Case, async: false

  alias OAuth2.Response

  import ExUnit.CaptureLog

  test "debug response body" do
    Application.put_env(:oauth2, :debug, true)

    output = capture_log(fn -> Response.new(%OAuth2.Client{}, 200, [{"content-type", "text/plain"}], "hello") end)
    assert output =~ ~s(OAuth2 Provider Response)
    assert output =~ ~s(body: "hello")

    Application.put_env(:oauth2, :debug, false)
  end

  test "text/plain body passes through body" do
    response = Response.new(%OAuth2.Client{}, 200, [{"content-type", "text/plain"}], "hello")
    assert response.body == "hello"
  end
end
