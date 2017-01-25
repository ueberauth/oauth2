defmodule OAuth2.UtilTest do
  use ExUnit.Case, async: true

  alias OAuth2.Util

  test "parses mime types" do
    assert "application/json" == Util.content_type([])
    assert "application/vnd.api+json" == Util.content_type([{"content-type", "application/vnd.api+json"}])
    assert "application/xml" == Util.content_type([{"content-type", "application/xml; version=1.0"}])
    assert "application/json" == Util.content_type([{"content-type", "application/json;param;param"}])

    assert_raise OAuth2.Error, fn ->
      Util.content_type([{"content-type", "trash; trash"}])
    end

    assert_raise OAuth2.Error, fn ->
      Util.content_type([{"content-type", "trash"}])
    end
  end
end
