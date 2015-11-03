defmodule OAuth2.AccessToken do
  @moduledoc """
  This module defines the `OAuth2.AccessToken` struct and provides functionality
  to make authorized requests to an OAuth2 provider using the AccessToken
  returned by the provider.

  The `OAuth2.AccessToken` struct is created for you when you use the
  `OAuth2.Client.get_token`

  ### Notes

  * If a full url is given (e.g. "http://www.example.com/api/resource") then it
  will use that otherwise you can specify an endpoint (e.g. "/api/resource") and
  it will append it to the `Client.site`.

  * The headers from the `Client.headers` are appended to the request headers.

  ### Examples

  ```
  token =  OAuth2.AccessToken.new("abc123", %OAuth2.Client{site: "www.example.com"})

  case OAuth2.AccessToken.get(token, "/some/resource") do
    {:ok, %OAuth2.Response{status_code: 401}} ->
      "Not Good"
    {:ok, %OAuth2.Response{status_code: status_code, body: body}} when status_code in [200..299] ->
      "Yay!!"
    {:error, %OAuth2.Error{reason: reason}} ->
      reason
  end

  response = OAuth2.AccessToken.get!(token, "/some/resource")

  response = OAuth2.AccessToken.post!(token, "/some/other/resources", %{foo: "bar"})
```

  """

  import OAuth2.Util

  alias OAuth2.Error
  alias OAuth2.Client
  alias OAuth2.Request
  alias OAuth2.Response
  alias OAuth2.AccessToken

  @standard ["access_token", "refresh_token", "expires_in", "token_type"]

  @type access_token  :: binary
  @type refresh_token :: binary
  @type expires_at    :: integer
  @type token_type    :: binary
  @type other_params  :: %{}
  @type body          :: binary | %{}

  @type t :: %__MODULE__{
              access_token:  access_token,
              refresh_token: refresh_token,
              expires_at:    expires_at,
              token_type:    token_type,
              other_params:  other_params,
              client:        Client.t}

  defstruct access_token: "",
            refresh_token: nil,
            expires_at: nil,
            token_type: "Bearer",
            other_params: %{},
            client: nil

  @doc """
  Returns a new `OAuth2.AccessToken` struct given the access token `string`.

  ### Example

  ```
  iex(1)> OAuth2.AccessToken.new("abc123", %OAuth2.Client{})
  %OAuth2.AccessToken{access_token: "abc123",
   client: %OAuth2.Client{authorize_url: "/oauth/authorize", client_id: "",
    client_secret: "", headers: [], params: %{}, redirect_uri: "", site: "",
    strategy: OAuth2.Strategy.AuthCode, token_method: :post,
    token_url: "/oauth/token"}, expires_at: nil, other_params: %{},
   refresh_token: nil, token_type: "Bearer"}
  ```

  """
  @spec new(binary, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"access_token" => token}, client)
  end

  @doc """
  Same as `new/2` except that the first arg is a `map`.

  Note if giving a map, please be sure to make the key a `string` no an `atom`.

  This is used by `OAuth2.Client.get_token/4` to create the `OAuth2.AccessToken` struct.

  ### Example

  ```
  iex(1)> OAuth2.AccessToken.new(%{"access_token" => "abc123"}, %OAuth2.Client{})
   %OAuth2.AccessToken{access_token: "abc123",
    client: %OAuth2.Client{authorize_url: "/oauth/authorize", client_id: "",
     client_secret: "", headers: [], params: %{}, redirect_uri: "", site: "",
     strategy: OAuth2.Strategy.AuthCode, token_method: :post,
     token_url: "/oauth/token"}, expires_at: nil, other_params: %{},
    refresh_token: nil, token_type: "Bearer"}
  ```
  """
  def new(response, client) do
    {std, other} = Dict.split(response, @standard)

    struct __MODULE__, [
      access_token:  std["access_token"],
      refresh_token: std["refresh_token"],
      expires_at:    (std["expires_in"] || other["expires"]) |> expires_at(),
      token_type:    std["token_type"] |> normalize_token_type(),
      other_params:  other,
      client:        client]
  end

  @doc """
  Makes a `GET` request to the given `url` using the `OAuth2.AccessToken`
  struct.
  """
  @spec get(t, binary, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def get(token, url, headers \\ [], opts \\ []),
    do: request(:get, token, url, "", headers, opts)

  @doc """
  Same as `get/4` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
  the request results in an error.
  """
  @spec get!(t, binary, Client.headers, Keyword.t) :: Response.t | Error.t
  def get!(token, url, headers \\ [], opts \\ []),
    do: request!(:get, token, url, "", headers, opts)

  @doc """
  Makes a `PUT` request to the given `url` using the `OAuth2.AccessToken`
  struct.
  """
  @spec put(t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def put(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:put, token, url, body, headers, opts)

  @doc """
  Same as `put/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
  the request results in an error.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec put!(t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def put!(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:put, token, url, body, headers, opts)

  @doc """
  Makes a `PATCH` request to the given `url` using the `OAuth2.AccessToken`
  struct.
  """
  @spec patch(t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def patch(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:patch, token, url, body, headers, opts)

  @doc """
  Same as `patch/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
  the request results in an error.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec patch!(t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def patch!(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:patch, token, url, body, headers, opts)

  @doc """
  Makes a `POST` request to the given URL using the `OAuth2.AccessToken`.
  """
  @spec post(t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def post(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:post, token, url, body, headers, opts)

  @doc """
  Same as `post/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
  if the request results in an error.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec post!(t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def post!(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:post, token, url, body, headers, opts)

  @doc """
  Makes a `DELETE` request to the given URL using the `OAuth2.AccessToken`.
  """
  @spec delete(t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def delete(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:delete, token, url, body, headers, opts)

  @doc """
  Same as `delete/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
  if the request results in an error.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec delete!(t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def delete!(token, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:delete, token, url, body, headers, opts)

  @doc """
  Makes a request of given type to the given URL using the `OAuth2.AccessToken`.
  """
  @spec request(atom, t, binary, body, Client.headers, Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def request(method, token, url, body \\ "", headers \\ [], opts \\ []) do
    url = process_url(token, url)
    headers = req_headers(token, headers)

    case Request.request(method, url, body, headers, opts) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Same as `request/6` but returns `OAuth2.Response` or raises an error if an
  error occurs during the request.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec request!(atom, t, binary, body, Client.headers, Keyword.t) :: Response.t | Error.t
  def request!(method, token, url, body \\ "", headers \\ [], opts \\ []) do
    case request(method, token, url, body, headers, opts) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @doc """
  Gets a new `AccessToken` by making a request using the refresh_token

  Returns an `AccessToken` struct that can then be used to access the resource API.
  """
  @spec refresh(t, Client.params, Client.headers, Keyword.t) :: {:ok, AccessToken.t} | {:error, Error.t}
  def refresh(token, params \\ [], headers \\ [], opts \\ [])
  def refresh(%{refresh_token: nil}, _params, _headers, _opts) do
    {:error, %Error{reason: "Refresh token not available."}}
  end
  def refresh(%{refresh_token: refresh_token, client: client}, params, headers, opts) do
    refresh =
      %{client | strategy: OAuth2.Strategy.Refresh}
      |> Client.put_param(:refresh_token, refresh_token)

    case Client.get_token(refresh, params, headers, opts) do
      {:ok, token}    -> {:ok, %{token | client: client}}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Calls `refresh/3` but raises `Error` if there an error occurs.
  """
  @spec refresh!(t, Client.params, Client.headers, Keyword.t) :: AccessToken.t | Error.t
  def refresh!(token, params \\ [], headers \\ [], opts \\ []) do
    case refresh(token, params, headers, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end


  @doc """
  Determines if the access token will expire or not.

  Returns `true` unless `expires_at` is `nil`.
  """
  @spec expires?(OAuth2.AccessToken.t) :: boolean
  def expires?(%AccessToken{expires_at: nil} = _token), do: false
  def expires?(_), do: true

  @doc """
  Determines if the access token has expired.
  """
  def expired?(token) do
    expires?(token) && unix_now > token.expires_at
  end

  @doc """
  Returns a unix timestamp based on now + expires_at (in seconds).
  """
  def expires_at(nil), do: nil
  def expires_at(val) when is_binary(val) do
    {int, _} = Integer.parse(val)
    int
  end
  def expires_at(int), do: unix_now + int

  defp process_url(token, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> token.client.site <> url
    end
  end

  defp normalize_token_type(nil), do: "Bearer"
  defp normalize_token_type("bearer"), do: "Bearer"
  defp normalize_token_type(string), do: string

  defp req_headers(token, headers) do
    [{"Authorization", "#{token.token_type} #{token.access_token}"} | headers] ++ token.client.headers
  end
end
