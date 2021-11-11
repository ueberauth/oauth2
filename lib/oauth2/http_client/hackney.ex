defmodule OAuth2.HTTPClient.Hackney do
  @behaviour OAuth2.HTTPClient

  @impl OAuth2.HTTPClient
  def request(method, url, headers, body, req_opts) do
    :hackney.request(method, url, headers, body, req_opts)
  end

  @impl OAuth2.HTTPClient
  def body(ref) do
    :hackney.body(ref)
  end
end
