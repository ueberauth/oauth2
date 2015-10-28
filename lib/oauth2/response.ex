defmodule OAuth2.Response do
  @moduledoc """
  Defines the `OAuth2.Response` struct which is created from the HTTP responses
  made by the `OAuth2.AccessToken` module.

  ## Struct fields

  * `status_code` - HTTP response status code
  * `headers` - HTTP response headers
  * `body` - Parsed HTTP response body (based on "Content-Type" header)
  """

  import OAuth2.Util

  @type status_code :: integer
  @type headers     :: map
  @type body        :: binary

  @type t :: %__MODULE__{status_code: integer,
                       headers: map,
                       body: binary}

  defstruct status_code: nil, headers: %{}, body: nil

  @doc false
  def new(status_code, headers, body) do
    %__MODULE__{
      status_code: status_code,
      headers: headers,
      body: decode_response_body(body, content_type(headers))
    }
  end

  defp parsers do
    %{json:  &Poison.decode!(&1),
      query: &URI.decode_query(&1),
      text:  &(&1)}
  end

  defp content_types do
    %{"application/json" => :json,
      "text/javascript" => :json,
      "application/x-www-form-urlencoded" => :query,
      "text/plain" => :query}
  end

  defp decode_response_body("", _type), do: ""
  defp decode_response_body(body, content_type) do
    content_type = content_types[content_type]
    parser = parsers[content_type] || &(&1)
    parser.(body)
  end
end
