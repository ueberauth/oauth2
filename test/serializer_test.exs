defmodule OAuth2.SerializerTest do
  use ExUnit.Case
  alias OAuth2.Serializer

  defmodule TestSerializer do
    def decode!(_), do: "decode_ok"
    def encode!(_), do: "encode_ok"
  end
  @json_mime "application/json"

  def with_serializers(serializers, fun) do
    backup = Application.get_env(:oauth2, :serializers)
    try do
      Application.put_env(:oauth2, :serializers, serializers)
      fun.()
    after
      Application.put_env(:oauth2, :serializers, backup)
    end
  end

  test "has default json serializer" do
    decoded = Serializer.decode!("{\"foo\": 1}", @json_mime)
    assert decoded == %{"foo" => 1}
  end

  test "accepts serializer override" do
    with_serializers(%{@json_mime => TestSerializer}, fn ->
      decoded = Serializer.decode!("{\"foo\": 1}", @json_mime)
      assert decoded == "decode_ok"

      encoded = Serializer.encode!(%{"foo" => 1}, @json_mime)
      assert encoded == "encode_ok"
    end)
  end

  test "raise error when serializers are misconfigured" do
    with_serializers(nil, fn ->
      assert_raise(RuntimeError, ~r/configuration/i, fn ->
        Serializer.decode!("{\"foo\": 1}", @json_mime)
      end)
    end)
  end
end

