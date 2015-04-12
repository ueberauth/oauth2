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

  @opts [
    client_id: "client_id",
    client_secret: "secret",
    site: "http://localhost:4999",
    redirect_uri: "http://localhost:4998/auth/callback"
  ]

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]

  plug :put_oauth2_client
  plug :match
  plug :dispatch

  get "/me" do
    conn
  end

  get "/auth" do
    conn
    |> put_resp_header("Location", OAuth2.authorize_url!(client(conn)))
    |> send_resp(302, "")
  end

  get "/auth/callback" do
    token = OAuth2.Client.get_token!(client(conn), code: conn.params["code"])
    send self, token
    conn
  end

  get "/" do
    conn
  end

  defp client(conn), do: conn.private.oauth2_client

  def put_oauth2_client(conn, _) do
    put_private(conn, :oauth2_client, OAuth2.new(@opts))
  end
end

