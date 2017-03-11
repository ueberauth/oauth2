defmodule OAuth2.Serializer.NullTest do
  use ExUnit.Case

  alias OAuth2.Serializer.Null

  test "encode!" do
    assert "hello" == Null.encode!("hello")
  end

  test "decode!" do
    assert "hello" == Null.decode!("hello")
  end
end
