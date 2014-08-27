defmodule OAuth2.Strategy.Password do
  @moduledoc """
  The Resource Owner Password Credentials Authorization Strategy.

  http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.3
  """
  use OAuth2.Strategy

  @doc """
  Not used for this strategy.
  """
  def authorize_url do
    raise "Not implemented."
  end

  @doc """
  Retrieve an access token given the specified End User username and password.
  """
  def get_token(client, username, password, params \\ %{}, opts \\ %{}) do
    params =
      %{grant_type: "password", username: username, password: password}
      |> Map.merge(Map.take(client, [:client_id, :client_secret]))
      |> Map.merge(params)

    Client.get_token(client, params, opts)
  end
end
