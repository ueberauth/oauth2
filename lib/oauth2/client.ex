defmodule OAuth2.Client do
  @moduledoc """
  Instantiate a new OAuth 2.0 client using the Client ID and Client Secret
  registered to your application.
  """

  use HTTPoison.Base
  require Logger

  alias OAuth2.Client

  defstruct [
    client_id: nil,
    client_secret: nil,
    strategy: nil,
    site: "",
    authorize_url: "/oauth/authorize",
    token_url: "/oauth/token",
    redirect_uri: nil
  ]

  def get_token(client, params \\ %{}, opts \\ %{}) do
  end
end
