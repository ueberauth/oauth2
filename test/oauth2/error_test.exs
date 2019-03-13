defmodule OAuth2.ErrorTest do
  use ExUnit.Case, async: false

  alias OAuth2.Error

  test "message" do
    assert Error.message(%Error{reason: :econnrefused}) == "Connection refused"
    assert Error.message(%Error{reason: "blah"}) == "blah"
    assert Error.message(%Error{reason: :blah}) == ":blah"
  end
end
