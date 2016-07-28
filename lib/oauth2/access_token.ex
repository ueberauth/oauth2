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
  token =  OAuth2.AccessToken.new("abc123")

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
              other_params:  other_params}

  defstruct access_token: "",
            refresh_token: nil,
            expires_at: nil,
            token_type: "Bearer",
            other_params: %{}

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
  @spec new(binary) :: t
  def new(token) when is_binary(token) do
    new(%{"access_token" => token})
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
  def new(response) when is_map(response) do
    {std, other} = Map.split(response, @standard)

    struct(AccessToken, [
      access_token:  std["access_token"],
      refresh_token: std["refresh_token"],
      expires_at:    (std["expires_in"] |> expires_at) || (other["expires"] |> expires),
      token_type:    std["token_type"] |> normalize_token_type(),
      other_params:  other
    ])
  end

  @doc """
  Determines if the access token will expire or not.

  Returns `true` unless `expires_at` is `nil`.
  """
  @spec expires?(AccessToken.t) :: boolean
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
    val
    |> Integer.parse
    |> elem(0)
    |> expires_at
  end
  def expires_at(int), do: unix_now + int

  @doc """
  Returns the expires value as an integer
  """
  def expires(nil), do: nil
  def expires(val) when is_binary(val) do
    val
    |> Integer.parse
    |> elem(0)
  end
  def expires(int), do: int

  defp normalize_token_type(nil), do: "Bearer"
  defp normalize_token_type("bearer"), do: "Bearer"
  defp normalize_token_type(string), do: string
end
