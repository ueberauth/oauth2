defmodule OAuth2.Request do
  @moduledoc false

  require Logger
  import OAuth2.Util

  alias OAuth2.{Client, Error, Response}

  @type body :: any

  @doc """
  Makes a request of given type to the given URL using the `OAuth2.AccessToken`.
  """
  @spec request(atom, Client.t(), binary, body, Client.headers(), Keyword.t()) ::
          {:ok, Response.t()} | {:ok, reference} | {:error, Response.t()} | {:error, Error.t()}
  def request(method, %Client{} = client, url, body, headers, opts) do
    url = client |> process_url(url) |> process_params(opts[:params])
    headers = req_headers(client, headers) |> Enum.uniq()
    content_type = content_type(headers)
    serializer = Client.get_serializer(client, content_type)
    body = encode_request_body(body, content_type, serializer)
    headers = process_request_headers(headers, content_type)
    req_opts = Keyword.merge(client.request_opts, opts)

    if Application.get_env(:oauth2, :debug) do
      Logger.debug("""
        OAuth2 Provider Request
        url: #{inspect(url)}
        method: #{inspect(method)}
        headers: #{inspect(headers)}
        body: #{inspect(body)}
        req_opts: #{inspect(req_opts)}
      """)
    end

    case :hackney.request(method, url, headers, body, req_opts) do
      {:ok, ref} when is_reference(ref) ->
        {:ok, ref}

      {:ok, status, headers, ref} when is_reference(ref) ->
        process_body(client, status, headers, ref)

      {:ok, status, headers, body} when is_binary(body) ->
        process_body(client, status, headers, body)

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
  @spec request!(atom, Client.t(), binary, body, Client.headers(), Keyword.t()) :: Response.t()
  def request!(method, %Client{} = client, url, body, headers, opts) do
    case request(method, client, url, body, headers, opts) do
      {:ok, resp} ->
        resp

      {:error, %Response{status_code: code, headers: headers, body: body}} ->
        raise %Error{
          reason: """
          Server responded with status: #{code}

          Headers:

          #{Enum.reduce(headers, "", fn {k, v}, acc -> acc <> "#{k}: #{v}\n" end)}
          Body:

          #{inspect(body)}
          """
        }

      {:error, error} ->
        raise error
    end
  end

  defp process_url(client, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> client.site <> url
    end
  end

  defp process_body(client, status, headers, ref) when is_reference(ref) do
    case :hackney.body(ref) do
      {:ok, body} ->
        process_body(client, status, headers, body)

      {:error, reason} ->
        {:error, %Error{reason: reason}}
    end
  end

  defp process_body(client, status, headers, body) when is_binary(body) do
    resp = Response.new(client, status, headers, body)

    case status do
      status when status in 200..399 ->
        {:ok, resp}

      status when status in 400..599 ->
        {:error, resp}
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

  defp encode_request_body("", _, _), do: ""
  defp encode_request_body([], _, _), do: ""

  defp encode_request_body(body, "application/x-www-form-urlencoded", _),
    do: URI.encode_query(body)

  defp encode_request_body(body, _mime, nil) do
    body
  end

  defp encode_request_body(body, _mime, serializer) do
    serializer.encode!(body)
  end
end
