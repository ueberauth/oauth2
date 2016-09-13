defmodule OAuth2.Request do
  @moduledoc false

  import OAuth2.Util

  alias OAuth2.{Client, Error, Response}

  @type body :: any

  @doc """
  Makes a request of given type to the given URL using the `OAuth2.AccessToken`.
  """
  @spec request(atom, Client.t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def request(method, %Client{} = client, url, body, headers, opts) do
    url = client |> process_url(url) |> process_params(opts[:params])
    headers = req_headers(client, headers)
    content_type = content_type(headers)
    body = encode_request_body(body, content_type)
    headers = process_request_headers(headers, content_type)

    case :hackney.request(method, url, headers, body, opts ++ [with_body: true]) do
      {:ok, status, headers, body} ->
        {:ok, Response.new(status, headers, body)}
      {:error, reason} ->
        {:error, %Error{reason: reason}}
    end
  end

  @doc """
  Same as `request/6` but returns `OAuth2.Response` or raises an error if an
  error occurs during the request.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec request!(atom, Client.t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def request!(method, %Client{} = client, url, body, headers, opts) do
    case request(method, client, url, body, headers, opts) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  defp process_url(client, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> client.site <> url
    end
  end

  defp process_params(url, nil),
    do: url
  defp process_params(url, params),
    do: url <> "?" <> URI.encode_query(params)

  defp req_headers(%Client{token: nil} = client, headers),
    do: headers ++ client.headers
  defp req_headers(%Client{token: token} = client, headers),
    do: [authorization_header(token) | headers] ++ client.headers

  defp authorization_header(token),
    do: {"authorization", "#{token.token_type} #{token.access_token}"}

  defp process_request_headers(headers, content_type) do
    case List.keyfind(headers, "accept", 0) do
      {"accept", _} ->
        headers
      nil ->
        [{"accept", content_type} | headers]
    end
  end

  defp encode_request_body("", _), do: ""
  defp encode_request_body([], _), do: ""
  defp encode_request_body(body, "application/x-www-form-urlencoded"),
    do: URI.encode_query(body)
  defp encode_request_body(body, type) do
    if serializer = Application.get_env(:oauth2, :serializers)[type] do
      serializer.encode!(body)
    else
      body
    end
  end
end
