defmodule OAuth2.Client do
  @moduledoc """
  Instantiate a new OAuth 2.0 client using the Client ID and Client Secret
  registered to your application.
  """

  use HTTPoison.Base
  require Logger

  alias OAuth2.Client
  def authorize_url(client, params \\ %{}) do
    client.strategy.authorize_url(params)
  end

  def get_token(client, params \\ %{}, opts \\ %{}) do
  end
end
