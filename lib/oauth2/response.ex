defmodule OAuth2.Response do
  @moduledoc """
  Defines the `OAuth2.Response` struct which is created from the HTTP responses
  made by the `OAuth2.AccessToken` module.

  ## Struct fields

  * `status_code` - HTTP response status code
  * `headers` - HTTP response headers
  * `body` - Parsed HTTP response body (based on "content-type" header)
  """

  import OAuth2.Util

  @type status_code :: integer
  @type headers     :: list
  @type body        :: binary | map

  @type t :: %__MODULE__{
    status_code: status_code,
    headers: headers,
    body: body
  }

  defstruct status_code: nil, headers: [], body: nil

  @doc false
  def new(status_code, headers, body) do
    %__MODULE__{
      status_code: status_code,
      headers: process_headers(headers),
      body: decode_response_body(body, content_type(headers))
    }
  end

  defp process_headers(headers) do
    Enum.map(headers, fn {k, v} -> {String.downcase(k), v} end)
  end

  defp decode_response_body("", _type), do: ""
  defp decode_response_body(" ", _type), do: ""
  defp decode_response_body(body, "application/x-www-form-urlencoded"),
    do: URI.decode_query(body)
  defp decode_response_body(body, "text/plain"),
    do: URI.decode_query(body)
  defp decode_response_body(body, type) do
    if serializer = Application.get_env(:oauth2, :serializers)[type] do
      serializer.decode!(body)
    else
      body
    end
  end
end
