defmodule OAuth2.Strategy.AuthCodeTest do

  defmodule Router do
    use Plug.Router
    import Plug.Conn

    plug Plug.Parsers, parsers: [:urlencoded, :multipart]

    get "/oauth/authorize" do
      conn
      |> put_resp_header("Location", "/auth/callback?code=1234")
      |> send_resp(302, "")
    end

    get "/auth/callback" do
      IO.puts inspect conn
      send self, {:conn, conn}
    end
  end
  use ExUnit.Case, async: true
  use Plug.Test

  alias OAuth2.Strategy.AuthCode

  @redirect_uri "http://localhost:4000/auth/callback"
  @encoded_redirect_uri URI.encode_query(%{redirect_uri: @redirect_uri})

  @opts [
    client_id: "client_id",
    client_secret: "secret",
    site: "http://localhost:4000"
  ]

  test "new" do
    strategy = AuthCode.new(@opts)
    assert strategy.client_id     == "client_id"
    assert strategy.client_secret == "secret"
    assert strategy.site          == "http://localhost:4000"
    assert strategy.authorize_url == "/oauth/authorize"
    assert strategy.token_url     == "/oauth/token"
    assert strategy.token_method  == :post
    assert strategy.params        == %{}
    assert strategy.headers       == %{}
  end

  test "authorize_url" do
    strategy = AuthCode.new(@opts)
    params = %{redirect_uri: @redirect_uri}
    url = AuthCode.authorize_url(strategy, params)
    assert url == "http://localhost:4000/oauth/authorize?client_id=client_id&#{@encoded_redirect_uri}&response_type=code"

    conn = Router.call(conn(:get, url), Router.init([]))
  end
end
