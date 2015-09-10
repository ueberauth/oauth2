defmodule OAuth2.AccessToken do
  @moduledoc """
  Provides functionality to make authorized requests to an OAuth2 provider.
  """

  import OAuth2.Util

  alias OAuth2.Error
  alias OAuth2.Client
  alias OAuth2.Request
  alias OAuth2.AccessToken

  @standard ["access_token", "refresh_token", "expires_in", "token_type"]

  @type access_token  :: binary
  @type refresh_token :: binary
  @type expires_at    :: integer
  @type token_type    :: binary
  @type other_params  :: %{}

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
  Returns a new AccessToken struct.
  """
  @spec new(Dict.t | String.t, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"access_token" => token}, client)
  end
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
  Makes a `GET` request to the given URL using the AccessToken.
  """
  def get(token, url, headers \\ [], opts \\ []), do: request(:get, token, url, body, headers, opts)

  @doc """
  Makes a `GET` request to the given URL using the AccessToken.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  def get!(token, url, headers \\ [], opts \\ []), do: request!(:get, token, url, body, headers, opts)

  @doc """
  Makes a `PUT` request to the given URL using the AccessToken.
  """
  def put(token, url, body \\ "", headers \\ [], opts \\ []), do: request(:put, token, url, body, headers, opts)

  @doc """
  Makes a `PUT` request to the given URL using the AccessToken.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  def put!(token, url, body \\ "", headers \\ [], opts \\ []), do: request!(:put, token, url, body, headers, opts)

  @doc """
  Makes a `POST` request to the given URL using the AccessToken.
  """
  def post(token, url, body \\ "", headers \\ [], opts \\ []), do: request(:post, token, url, body, headers, opts)

  @doc """
  Makes a `POST` request to the given URL using the AccessToken.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  def post!(token, url, body \\ "", headers \\ [], opts \\ []), do: request!(:post, token, url, body, headers, opts)

  @doc """
  Makes a request of given type to the given URL using the AccessToken.
  """
  def request(method, token, url, body \\ "", headers \\ [], opts \\ []) do
    case Request.request(method, process_url(token, url), req_headers(token, headers), opts) do
      {:ok, response} -> {:ok, response.body}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  @doc """
  Makes a request of given type to the given URL using the AccessToken.

  An `OAuth2.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  def request!(method, token, url, body \\ "", headers \\ [], opts \\ []) do
    case Request.request(method, process_url(token, url), req_headers(token, headers), opts) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  @doc """
  Determines if the access token expires or not.

  Returns `true` unless `expires_at` is `nil`.
  """
  def expires?(%AccessToken{expires_at: nil}), do: false
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
    [{"Authorization", "#{token.token_type} #{token.access_token}"} | headers]
  end
end
