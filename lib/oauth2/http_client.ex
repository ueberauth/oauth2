defmodule OAuth2.HttpClient do
  @moduledoc """
  Specification for a OAuth2 HTTP Client. The client is a module that implements
  the `OAuth2.HttpClient` behaviour. To configure OAuth2 to use the HTTP client,
  you can set the `:http_client` option:

  ```elixir
  config :oauth2, http_client: MyClient
  ```

  The behaviour is designed to match `m:Tesla` clients, so you can use `Tesla`
  as the HTTP client

  ```elixir
  config :oauth2, http_client: Tesla
  ```
  """

  @type option ::
          {:method, method}
          | {:url, url}
          | {:query, query}
          | {:headers, headers}
          | {:body, body}
          | {:opts, opts}

  @type method :: :get | :delete | :post | :put | :patch
  @type url :: binary
  @type param :: binary | [{binary | atom, param}]
  @type query :: [{binary | atom, param}]
  @type headers :: [{binary, binary}]

  @type body :: any
  @type status :: integer | nil
  @type opts :: keyword

  @type response ::
          %{
            status: status,
            headers: headers,
            body: body
          }

  @doc """
  Callback to make a HTTP request. It matches `Tesla.request/1`
  """
  @callback request([option]) :: {:ok, response} | {:error, any}

  @doc """
  Callback to make a HTTP request. It matches `Tesla.request/2`

  This callback will be used if you specify `:http_client` as a tuple `{term,
  ClientModule}`. For more info see examples in `OAuth2.Client.new/1`
  """
  @callback request(any, [option]) :: {:ok, any} | {:error, any}

  @optional_callbacks request: 1, request: 2
end
