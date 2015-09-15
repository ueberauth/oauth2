defmodule OAuth2.Response do
  @moduledoc """
  Defines a response struct from the HTTP response.

  ## Struct fields

  * `status_code` - HTTP response status code
  * `headers` - HTTP response headers
  * `body` - HTTP response body (parsed based on "Content-Type" header)
  """

  @type t :: %__MODULE__{status_code: integer, body: binary, headers: map}

  defstruct status_code: nil, body: nil, headers: %{}

  @query ["application/x-www-form-urlencoded", "text/plain"]

  @doc """
  Builds a new response struct from the HTTP response.

  The response body is automatically parsed if the "Content-Type" is either:

  * application/x-www-form-urlencoded
  * text/plain
  * application/json
  """
  def new(status_code, headers, body) do
    content_type = OAuth2.Util.content_type(headers)
    %__MODULE__{
      status_code: status_code,
      headers: headers,
      body: decode_response_body(body, content_type)
    }
  end

  defp decode_response_body(body, "application/json"), do:
    Poison.decode!(body)
  defp decode_response_body(body, type) when type in @query, do:
    URI.query_decoder(body) |> Enum.map(&(&1)) |> Enum.into(%{})
  defp decode_response_body(body, _), do: body
end
