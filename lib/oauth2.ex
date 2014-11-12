defmodule OAuth2 do
  @moduledoc """
  OAuth2
  """

  alias OAuth2.Error
  alias OAuth2.Request
  alias OAuth2.Strategy
  alias OAuth2.AccessToken

  @doc """
  The authorize endpoint URL of the OAuth2 provider
  """
  def authorize_url(strategy, params \\ %{}) do
    struct(strategy, params: Map.merge(strategy.params, params))
    |> Strategy.to_url(:authorize_url)
  end

  @doc """
  The token endpoint URL of the OAuth2 provider
  """
  def token_url(strategy, params \\ %{}) do
    struct(strategy, params: Map.merge(strategy.params, params))
    |> Strategy.to_url(:token_url)
  end

  end
end
