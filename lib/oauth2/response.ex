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

  @doc """
  Builds a new `OAuth2.Response` struct from the HTTP response.

  The response body is automatically parsed if the "Content-Type" is either:
  
  * application/x-www-form-urlencoded - parsed using `Plug.Conn.Query.decode/1`
  * text/plain - parsed using `Plug.Conn.Query.decode/1`
  * application/json - parsed using `Poison.decode!/1`
  * text/javascript - parsed using `Poison.decode!/1`
  """
  @spec new(status_code, headers, body) :: t
  def new(status_code, headers, body) do
    %__MODULE__{
      status_code: status_code,
      headers: headers,
      body: decode_response_body(body, content_type(headers))
    }
  end

  @spec parsers() :: %{key: (binary -> any)}
  def parsers do
    %{json:  &Poison.decode!(&1),
      query: &Plug.Conn.Query.decode(&1),
      text:  &(&1)}
  end

  @spec content_types() :: %{binary => atom}
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
