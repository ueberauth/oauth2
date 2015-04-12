defmodule OAuth2 do
  @moduledoc """
  The OAuth2 specification

  http://tools.ietf.org/html/rfc6749

  The OAuth 2.0 authorization framework enables a third-party
  application to obtain limited access to an HTTP service, either on
  behalf of a resource owner by orchestrating an approval interaction
  between the resource owner and the HTTP service, or by allowing the
  third-party application to obtain access on its own behalf.
  """

  use Behaviour

  alias OAuth2.Client

  @type opts    :: Keyword.t
  @type param   :: binary | %{binary => param} | [param]
  @type params  :: %{binary => param}
  @type headers :: [{binary, binary}]

  defcallback authorize_url(Client.t, params) :: binary
  defcallback get_token(Client.t, params, headers) :: Client.t

  defdelegate new(opts), to: Client
  defdelegate authorize_url(client), to: Client
  defdelegate authorize_url(client, params), to: Client
  defdelegate authorize_url!(client), to: Client
  defdelegate authorize_url!(client, params), to: Client

  defmacro __using__(_) do
    quote do
      @behaviour OAuth2
      import OAuth2.Client
    end
  end
end

