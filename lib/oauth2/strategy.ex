defmodule OAuth2.Strategy do

  defmacro __using__(_opts) do
    quote location: :keep do
      alias OAuth2.Strategy

      defstruct [
        client_id: nil,
        client_secret: nil,
        site: "",
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token",
        token_method: :post,
        params: %{},
        headers: %{}
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
    strategy.site <> Map.get(strategy, endpoint) <> "?" <> URI.encode_query(strategy.params)
  end
end

