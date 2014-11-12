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

  @doc """
  Initializes an AccessToken by making a request to the token endpoint.

  Returns an `AccessToken` struct that can then be used to access the resource API.

  ## Arguments

  * `strategy` - a struct of the strategy in use.
  * `params`   - a map of additional request parameters.
  * `opts`     - a keyword list of opts used for the request and token.
  """
  def get_token(strategy, params \\ %{}, opts \\ [])

  def get_token(%{token_method: :post} = strategy, params, opts) do
    {headers, body} = Map.pop(params, :headers, [])
    case Request.post(token_url(strategy), body, post_headers(headers), opts) do
      {:ok, response}  -> {:ok, AccessToken.new(response.body, strategy, opts)}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end
  def get_token(strategy, params, opts) do
    case Request.get(token_url(strategy, params), opts) do
      {:ok, response}  -> {:ok, AccessToken.new(response.body, strategy, opts)}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  def post_headers(headers) do
    [{"Content-Type", "application/x-www-form-urlencoded"} | headers]
  end
end

