defmodule OAuth2.Serializer.Null do
  @moduledoc false

  @behaviour OAuth2.Serializer

  @doc false
  def decode!(data), do: data

  @doc false
  def encode!(data), do: data

  @doc false
  def maybe_warn_missing_serializer(mime) do
    if Application.get_env(:oauth2, :warn_missing_serializer, true) do
      require Logger

      Logger.warn """

      A serializer was not configured for content-type '#{mime}'.

      To remove this warning for this content-type, consider registering a serializer:

          OAuth2.Client.put_serializer(client, "#{mime}", MySerializer)

      To remove this warning entirely, add the following to your `config.exs` file:

          config :oauth2,
            warn_missing_serializer: false
      """
    end
  end
end
