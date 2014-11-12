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
    strategy.__struct__.authorize_url(strategy, params)
    |> to_url(:authorize_url)
  end

  @doc """
  The token endpoint URL of the OAuth2 provider
  """
  def token_url(strategy, params \\ %{}, opts \\ %{}) do
    strategy.__struct__.token_url(strategy, params, opts)
    |> to_url(:token_url)
  end

  defp to_url(strategy, endpoint) do
    strategy.site <> Map.get(strategy, endpoint) <> "?" <> URI.encode_query(strategy.params)
  end
end
