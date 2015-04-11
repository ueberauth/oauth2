defmodule OAuth2.Strategy.AuthCode do
  @moduledoc """
  The Authorization Code Strategy.

  http://tools.ietf.org/html/rfc6749#section-1.3.1
  """

  use OAuth2.Strategy

  @doc """
  The authorization URL endpoint of the provider.
  params additional query parameters for the URL
  """
  def authorize_url(strategy, params \\ %{}) do
    params = Map.merge(%{
      response_type: "code",
      client_id: strategy.client_id
    }, params)

    OAuth2.authorize_url(strategy, params)
  end

  @doc """
  Retrieve an access token given the specified validation code.
  """
  def get_token(strategy, code, params \\ %{}, opts \\ []) do
    params = Map.merge(%{
      code: code,
      grant_type: "authorization_code",
      client_id: strategy.client_id,
      client_secret: strategy.client_secret,
      redirect_uri: strategy.redirect_uri
    }, params)
    OAuth2.get_token(strategy, params, opts)
  end

  def get_token!(strategy, code, params \\ %{}, opts \\ []) do
    case get_token(strategy, code, params, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end
end

