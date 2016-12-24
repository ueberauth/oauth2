defmodule OAuth2.Serializer do
  @moduledoc false

  defmodule NullSerializer do
    @moduledoc false
    def decode!(content), do: content
    def encode!(content), do: content
  end

  def decode!(content, type), do: serializer(type).decode!(content)
  def encode!(content, type), do: serializer(type).encode!(content)

  defp serializer(type) do
    configured_serializers
    |> Map.get(type, NullSerializer)
  end

  defp configured_serializers do
    Application.get_env(:oauth2, :serializers) ||
      raise("Missing serializers configuration! Make sure oauth2 app is added to mix application list")
  end
end

