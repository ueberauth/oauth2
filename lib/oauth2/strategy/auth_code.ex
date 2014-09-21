defmodule OAuth2.Strategy.AuthCode do
  @moduledoc """
  The Authorization Code Strategy.

  http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.1
  """

  use OAuth2.Strategy

  @doc """
  The required query parameters for the authorize URL.
  """
  def authorize_params(client, params \\ %{}) do
    Map.merge(params, %{response_type: "code", client_id: client.client_id})
  end

  @doc """
  The authorization URL endpoint of the provider.
  """
  def authorize_url(client, params \\ %{}) do
    params = Map.merge(authorize_params(client, params), params)
    Client.authorize_url(client, params)
  end

  @doc """
  Retrieve an access token given the specified validation code.
  """
  def get_token(client, params \\ %{}, opts \\ %{}) do
    params = %{grant_type: "authorization_code", code: client.code}
    |> Map.merge(%{client_id: client.client_id, client_secret: client.client_secret})
    |> Mag.merge(params)

    Client.get_token(client, params, opts)
  end
end
