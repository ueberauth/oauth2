defmodule OAuth2.Strategy do

  alias OAuth2.Client

  defmacro __using__(_opts) do
    quote do
      alias OAuth2.Client

      def new(client) do
        client = Dict.merge(client, [strategy: __MODULE__])
        struct(Client, client)
      end
    end
  end
end
