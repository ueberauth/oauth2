defmodule OAuth2.AccessToken do

  import OAuth2.Util

  alias OAuth2.Error
  alias OAuth2.Request
  alias OAuth2.AccessToken

  @standard ["access_token", "refresh_token", "expires_in", "token_type"]

  defstruct [
    access_token: "",
    refresh_token: nil,
    expires_at: nil,
    token_type: "Bearer",
    other_params: %{},
    strategy: nil
  ]

  def new(response, strategy, _opts \\ []) do
    {std, other} = Dict.split(response, @standard)

    struct __MODULE__, [
      access_token:  std["access_token"],
      refresh_token: std["refresh_token"],
      token_type:    response["token_type"] |> normalize_token_type,
      expires_at:    (std["expires_in"] || other["expires"]) |> expires_at(),
      other_params:  other,
      strategy:      strategy]
  end

  def get(token, url, headers \\ [], opts \\ []) do
    case Request.get(process_url(token, url), req_headers(token, headers), opts) do
      {:ok, response} -> {:ok, response.body}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end
  def get!(token, url, headers \\ [], opts \\ []) do
    case get(token, url, req_headers(token, headers), opts) do
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
      _ -> token.strategy.site <> url
    end
  end

  defp normalize_token_type("bearer"), do: "Bearer"
  defp normalize_token_type(string), do: string

  defp req_headers(token, headers) do
    [{"Authorization", "#{token.token_type} #{token.access_token}"} | headers]
  end
end
