defmodule OAuth2.Strategy.AuthCode do
  @moduledoc """
  The Authorization Code Strategy.

  http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.1
  """

  use OAuth2.Strategy

  @doc """
  The authorization URL endpoint of the provider.
  params additional query parameters for the URL
  """
  def authorize_url(strategy, params \\ %{}) do
    params = %{response_type: "code", client_id: strategy.client_id}
    |> Map.merge(params)

    %__MODULE__{strategy | params: params}
  end

  @doc """
  Retrieve an access token given the specified validation code.
  """
  def token_url(strategy, params \\ %{}, opts \\ %{}) do
    params = %{grant_type: "authorization_code"}
    |> Map.merge(%{client_id: strategy.client_id, client_secret: strategy.client_secret})
    |> Map.merge(params)

    %__MODULE__{strategy | params: params}
  end
end
