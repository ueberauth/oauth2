defmodule OAuth2.Client do
  @moduledoc """
  OAuth2 Client

  This module is responsible for building and establishing a request for an
  access token.
  """

  @type strategy      :: module
  @type client_id     :: binary
  @type client_secret :: binary
  @type site          :: binary
  @type authorize_url :: binary
  @type token_url     :: binary
  @type token_method  :: :post | :get | atom
  @type redirect_uri  :: binary

  @type t :: %__MODULE__{
              strategy:      strategy,
              client_id:     client_id,
              client_secret: client_secret,
              site:          site,
              authorize_url: authorize_url,
              token_url:     token_url,
              token_method:  token_method,
              params:        OAuth2.params,
              headers:       OAuth2.headers,
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
  alias OAuth2.Strategy
  alias OAuth2.AccessToken

  @doc """
  Builds a new
  """
  @spec new(Keyword.t) :: t
  def new(opts), do: struct(__MODULE__, opts)

  @doc """
  Builds a url from the strategy struct.
  """
  @spec to_url(t, atom) :: binary
  def to_url(client, endpoint) do
    endpoint = Map.get(client, endpoint)
    url = endpoint(client, endpoint) <> "?" <> URI.encode_query(client.params)
    {client, url}
  end

  @doc """
  Puts the specified `value` in the params for the given `key`.

  The key can be a string or an atom, atoms are automatically
  convert to strings.
  """
  @spec put_param(t, String.t | atom, any) :: t
  def put_param(%Client{params: params} = client, key, value) do
    %{client | params: Map.put(params, param_key(key), value)}
  end

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

  @spec put_headers(t, list) :: t
  def put_headers(%Client{} = client, []), do: client
  def put_headers(%Client{} = client, [{k,v}|rest]) do
    client |> put_header(k,v) |> put_headers(rest)
  end

  @doc """
  The authorize endpoint URL of the OAuth2 provider
  """
  @spec authorize_url(t, list) :: binary
  def authorize_url(client, params \\ []) do
    client.strategy.authorize_url(client, params) |> to_url(:authorize_url)
  end

  @spec authorize_url!(t, list) :: binary
  def authorize_url!(client, params \\ []) do
    {_, url} = authorize_url(client, params)
    url
  end

  @doc """
  Initializes an AccessToken by making a request to the token endpoint.

  Returns an `AccessToken` struct that can then be used to access the resource API.

  ## Arguments

  * `strategy` - a struct of the strategy in use, defaults to `OAuth2.Strategy.AuthCode`
  * `params`   - a keyword list of request parameters
  * `headers`  - a list of request headers
  """
  def get_token(%{token_method: method} = client, params \\ [], headers \\ []) do
    {client, url} = token_url(client, params, headers)
    case apply(Request, method, [url, client.params, client.headers]) do
      {:ok, response} -> {:ok, AccessToken.new(response.body, client)}
      {:error, error} -> {:error, %Error{reason: error}}
    end
  end

  def get_token!(client, params \\ [], headers \\ []) do
    case get_token(client, params, headers) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
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
