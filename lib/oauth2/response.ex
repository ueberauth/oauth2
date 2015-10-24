defmodule OAuth2.Response do
  @moduledoc """
  Defines a response struct from the HTTP response.

  ## Struct fields

  * `status_code` - HTTP response status code
  * `headers` - HTTP response headers
  * `body` - Parsed HTTP response body (based on "Content-Type" header)
  """

  import OAuth2.Util

  alias OAuth2.Response

  @type t :: %Response{status_code: integer,
                       headers: map,
                       body: binary}

  defstruct status_code: nil, headers: %{}, body: nil

  @doc """
  Builds a new response struct from the HTTP response.

  The response body is automatically parsed if the "Content-Type" is either:

  * application/x-www-form-urlencoded
  * text/plain
  * application/json
  """
  def new(status_code, headers, body) do
    %Response{
      status_code: status_code,
      headers: headers,
      body: decode_response_body(body, content_type(headers))
    }
  end

  def parsers do
    %{json:  &Poison.decode!(&1),
      query: &Plug.Conn.Query.decode(&1),
      text:  &(&1)}
  end

  def content_types do
    %{"application/json" => :json,
      "text/javascript" => :json,
      "application/x-www-form-urlencoded" => :query,
      "text/plain" => :query}
  end

  defp decode_response_body("", _type), do: ""
  defp decode_response_body(body, content_type) do
    content_type = content_types[content_type]
    parser = parsers[content_type]
    parser.(body)
  end
end
