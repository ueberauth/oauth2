defmodule OAuth2.Request do
  use HTTPoison.Base

  alias OAuth2.Error
  alias OAuth2.Response

  def request(method, url, body \\ "", headers \\ [], opts \\ []) do
    content_type = OAuth2.Util.content_type(headers)
    url = process_url(to_string(url))
    body = process_request_body(body, content_type)
    headers = process_request_headers(headers, content_type)
    :hackney.request(method, url, headers, body, opts) |> do_request
  end

  def request!(method, url, body \\ "", headers \\ [], options \\ []) do
    case request(method, url, body, headers, options) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  defp process_request_headers(headers, content_type), do:
    [{"Accept", content_type} | headers]

  defp process_request_body(body, "application/json"), do:
    Poison.encode!(body)
  defp process_request_body(body, "application/x-www-form-urlencoded"), do:
    Plug.Conn.Query.encode(body)

  defp do_request({:ok, status_code, headers, client}) when status_code in [205, 304], do:
    {:ok, Response.new(status_code, headers, "")}
  defp do_request({:ok, status_code, headers}), do:
    {:ok, Response.new(status_code, headers, "")}
  defp do_request({:ok, status_code, headers, client}), do:
    handle_request_body(:hackney.body(client), status_code, headers)
  defp do_request({:error, reason}), do:
    {:error, %Error{reason: reason}}

  defp handle_request_body({:ok, body}, status_code, headers), do:
    {:ok, Response.new(status_code, headers, body)}
  defp handle_request_body({:error, reason}, _status_code, _headers), do:
    {:error, %Error{reason: reason}}
end
