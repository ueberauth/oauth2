defmodule OAuth2.Strategy.ClientCredentials do
  @moduledoc """
  The Client Credentials Strategy

  http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.4
  """
  use OAuth2.Strategy

  @doc """
  Not used for this strategy.
  """
  def authorize_url do
    raise "Not implemented."
  end

  @doc """
  Retrieve an access token given the specified strategy.
  """
  def get_token(strategy, params \\ %{}, opts \\ %{}) do
    {auth_scheme, opts} = Map.pop(opts, :auth_scheme, "auth_header")
    params =
      %{grant_type: "client_credentials"}
      |> Map.merge(auth_scheme(auth_scheme, strategy))
      |> Map.merge(params)

    OAuth.get_token(strategy, params, Map.merge(opts, %{refresh_token: nil}))
  end

  @doc """
  Returns the Authorization header value for Basic Authentication.
  """
  def auth_header(%{client_id: id, client_secret: secret}) do
    %{headers: %{"Authorization" => "Basic " <> Base.encode64(id <> ":" <> secret)}}
  end

  defp auth_scheme("auth_header", strategy),  do: auth_header(strategy)
  defp auth_scheme("request_body", strategy), do: Map.take(strategy, [:client_id, :client_secret])
end
