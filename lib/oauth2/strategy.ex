defmodule OAuth2.Strategy do

  defmacro __using__(_opts) do
    quote location: :keep do
      alias OAuth2.Strategy

      defstruct [
        client_id: nil,
        client_secret: nil,
        site: "",
        scope: nil,
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token",
        token_method: :post,
        params: %{},
        headers: %{},
        redirect_uri: ""
      ]

      def new(opts) do
        struct(__MODULE__, opts)
      end
    end
  end

  @doc """
  Builds a url from the strategy struct.
  """
  def to_url(strategy, endpoint) do
    endpoint = Map.get(strategy, endpoint)
    endpoint(strategy, endpoint) <> "?" <> URI.encode_query(strategy.params)
  end

  defp endpoint(strategy, <<"/"::utf8, _::binary>> = endpoint), do:
    strategy.site <> endpoint
  defp endpoint(_strategy, endpoint), do:
    endpoint
end
