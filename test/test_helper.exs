ExUnit.start

defmodule Provider do
  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]

  plug :match
  plug :dispatch

  get "/oauth/authorize" do
    redirect_uri = conn.params["redirect_uri"]
    conn
    |> put_resp_header("Location", redirect_uri <> "?" <> "code=1234")
    |> send_resp(302, "")
  end

  post "/oauth/token" do
    token = %{expires_in: 3600, access_token: "abc123", token_type: "bearer"}
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(token))
  end

end

defmodule Client do
  use Plug.Router
  import Plug.Conn

  alias OAuth2.Strategy.AuthCode

  @redirect_uri "http://localhost:4001/auth/callback"
  @params %{redirect_uri: @redirect_uri}

  @opts [
    client_id: "client_id",
    client_secret: "secret",
    site: "http://localhost:4000"
  ]

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]

  plug :put_oauth_strategy
  plug :match
  plug :dispatch

  get "/me" do
    conn
  end

  get "/auth" do
    conn
    |> put_resp_header("Location", AuthCode.authorize_url(strategy(conn), @params))
    |> send_resp(302, "")
  end

  get "/auth/callback" do
    token = AuthCode.get_token!(strategy(conn), conn.params["code"], @params)
    send self, token
    conn
  end

  get "/" do
    conn
  end

  defp strategy(conn), do: conn.private.oauth2_strategy

  def put_oauth_strategy(conn, _) do
    put_private(conn, :oauth2_strategy, AuthCode.new(@opts))
  end
end

