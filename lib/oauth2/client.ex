defmodule OAuth2.Client do
  @moduledoc """
  This module defines the `OAuth2.Client` struct and is responsible for building
  and establishing a request for an access token.
  """

  @type strategy      :: module
  @type client_id     :: binary
  @type client_secret :: binary
  @type site          :: binary
  @type authorize_url :: binary
  @type token_url     :: binary
  @type token_method  :: :post | :get | atom
  @type redirect_uri  :: binary
  @type param         :: binary | %{binary => param} | [param]
  @type params        :: %{binary => param}
  @type headers       :: [{binary, binary}]



  @type t :: %__MODULE__{
              strategy:      strategy,
              client_id:     client_id,
              client_secret: client_secret,
              site:          site,
              authorize_url: authorize_url,
              token_url:     token_url,
              token_method:  token_method,
              params:        params,
              headers:       headers,
              redirect_uri:  redirect_uri}

  defstruct strategy: OAuth2.Strategy.AuthCode,
            client_id: "",
            client_secret: "",
            site: "",
            authorize_url: "/oauth/authorize",
            token_url: "/oauth/token",
            token_method: :post,
            params: %{},
            headers: [],
            redirect_uri: ""

  alias OAuth2.Error
  alias OAuth2.Client
  alias OAuth2.Request
  alias OAuth2.AccessToken

  @doc """
  Builds a new OAuth2 client struct using the `opts` provided.

  ## Client struct fields

  * `strategy` - a module that implements the appropriate OAuth2 strategy,
    default `OAuth2.Strategy.AuthCode`
  * `client_id` - the client_id for the OAuth2 provider
  * `client_secret` - the client_secret for the OAuth2 provider
  * `site` - the OAuth2 provider site host
  * `authorize_url` - absolute or relative URL path to the authorization
    endpoint. Defaults to `"/oauth/authorize"`
  * `token_url` - absolute or relative URL path to the token endpoint.
    Defaults to `"/oauth/token"`
  * `token_method` - HTTP method to use to request token (`:get` or `:post`).
    Defaults to `:post`
  * `params` - a map of request parameters
  * `headers` - a list of request headers
  * `redirect_uri` - the URI the provider should redirect to after authorization
     or token requests
  """
  @spec new(Keyword.t) :: t
  def new(opts), do: struct(__MODULE__, opts)

  @doc """
  Puts the specified `value` in the params for the given `key`.

  The key can be a `string` or an `atom`. Atoms are automatically
  convert to strings.
  """
  @spec put_param(t, String.t | atom, any) :: t
  def put_param(%Client{params: params} = client, key, value) do
    %{client | params: Map.put(params, param_key(key), value)}
  end

  @doc """
  Set multiple params in the client in one call.
  """
  @spec merge_params(t, OAuth2.params) :: t
  def merge_params(client, params) do
    params = Enum.reduce(params, %{}, fn {k,v}, acc ->
      Map.put(acc, param_key(k), v)
    end)
    %{client | params: Map.merge(client.params, params)}
  end

  @doc """
  Adds a new header `key` if not present, otherwise replaces the
  previous value of that header with `value`.
  """
  @spec put_header(t, binary, binary) :: t
  def put_header(%Client{headers: headers} = client, key, value) when
    is_binary(key) and is_binary(value) do
    %{client | headers: List.keystore(headers, key, 0, {key, value})}
  end

  @doc """
  Set multiple headers in the client in one call.
  """
  @spec put_headers(t, list) :: t
  def put_headers(%Client{} = client, []), do: client
  def put_headers(%Client{} = client, [{k,v}|rest]) do
    client |> put_header(k,v) |> put_headers(rest)
  end

  @doc false
  @spec authorize_url(t, list) :: {t, binary}
  def authorize_url(client, params \\ []) do
    client.strategy.authorize_url(client, params) |> to_url(:authorize_url)
  end

  @doc """
  Returns the authorize url based on the client configuration.

  ## Example

      redirect_url = OAuth2.Client.authorize_url!(%OAuth2.Client{})
  """
  @spec authorize_url!(t, list) :: binary
  def authorize_url!(client, params \\ []) do
    {_, url} = authorize_url(client, params)
    url
  end

  @doc """
  Initializes an `OAuth2.AccessToken` struct by making a request to the token
  endpoint.

  Returns an `OAuth2.AccessToken` struct that can then be used to access the
  provider's RESTful API.

  ## Arguments

  * `client` - a `OAuth2.Client` struct with the strategy to use, defaults to
    `OAuth2.Strategy.AuthCode`
  * `params` - a keyword list of request parameters
  * `headers` - a list of request headers
  * `opts` - a `Keyword` list of options

  ## Options

  * `:timeout` - the timeout (in milliseconds) of the request
  * `:proxy` - a proxy to be used for the request; it can be a regular url or a
   `{Host, Proxy}` tuple
  """
  @spec get_token(t, params, headers, Keyword.t) :: {:ok, AccessToken.t} | {:error, Error.t}
  def get_token(%{token_method: method} = client, params \\ [], headers \\ [], opts \\ []) do
    {client, url} = token_url(client, params, headers)
    case Request.request(method, url, client.params, client.headers, opts) do
      {:ok, response} -> {:ok, AccessToken.new(response.body, client)}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Same as `get_token/4` but raises `OAuth2.Error` if an error occurs during the
  request.
  """
  @spec get_token!(t, params, headers, Keyword.t) :: AccessToken.t | Error.t
  def get_token!(client, params \\ [], headers \\ [], opts \\ []) do
    case get_token(client, params, headers, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end

  defp to_url(%Client{token_method: :post} = client, :token_url) do
    {client, endpoint(client, client.token_url)}
  end

  defp to_url(client, endpoint) do
    endpoint = Map.get(client, endpoint)
    url = endpoint(client, endpoint) <> "?" <> URI.encode_query(client.params)
    {client, url}
  end

  defp token_url(client, params, headers) do
    client
    |> token_post_header()
    |> client.strategy.get_token(params, headers)
    |> to_url(:token_url)
  end

  defp token_post_header(%Client{token_method: :post} = client) do
    put_header(client, "Content-Type", "application/x-www-form-urlencoded")
  end
  defp token_post_header(%Client{} = client), do: client

  defp param_key(binary) when is_binary(binary), do: binary
  defp param_key(atom) when is_atom(atom), do: Atom.to_string(atom)

  defp endpoint(client, <<"/"::utf8, _::binary>> = endpoint),
    do: client.site <> endpoint
  defp endpoint(_client, endpoint), do: endpoint
end
