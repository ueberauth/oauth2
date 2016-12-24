defmodule OAuth2.SerializerTest do
  use ExUnit.Case
  import OAuth2.TestHelpers
  alias OAuth2.Serializer

  defmodule TestSerializer do
    def decode!(_), do: "decode_ok"
    def encode!(_), do: "encode_ok"
  end
  @json_mime "application/json"

  def set_json_serializer(serializer) do
    Application.put_env(:oauth2, :serializers, %{@json_mime => serializer})
  end

  test "has default json serializer" do
    decoded = Serializer.decode!("{\"foo\": 1}", @json_mime)
    assert decoded == %{"foo" => 1}
  end

  test "accepts serializer override" do
    set_json_serializer(TestSerializer)

    decoded = Serializer.decode!("{\"foo\": 1}", @json_mime)
    assert decoded == "decode_ok"

    encoded = Serializer.encode!(%{"foo" => 1}, @json_mime)
    assert encoded == "encode_ok"
  end

  test "raise error when serializers are misconfigured" do
    Application.put_env(:oauth2, :serializers, nil)

    assert_raise(RuntimeError, ~r/configuration/i, fn ->
      Serializer.decode!("{\"foo\": 1}", @json_mime)
    end)
  end
end

