defmodule OAuth2.UtilTest do
  use ExUnit.Case, async: true

  alias OAuth2.Util

  test "parses mime types" do
    assert "application/json" == Util.content_type([])

    assert_raise OAuth2.Error, fn ->
      Util.content_type([{"content-type", "trash; trash"}])
    end
  end
end
