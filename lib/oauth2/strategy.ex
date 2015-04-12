defmodule OAuth2.Strategy do
  use Behaviour

  alias OAuth2.Client

  defcallback authorize_url(Client.t, OAuth2.params) :: binary
  defcallback get_token(Client.t, OAuth2.params, OAuth2.headers) :: Client.t

  defmacro __using__(_) do
    quote do
      @behaviour OAuth2
      import OAuth2.Client
    end
  end
end
