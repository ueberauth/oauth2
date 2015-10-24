defmodule ConsumerRouter do
  use Plug.Router
  import Plug.Conn
  import OAuth2.TestHelpers

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug :put_oauth2_client
  plug :match
  plug :dispatch

  get "/auth" do
    conn
    |> put_resp_header("location", OAuth2.Client.authorize_url!(client(conn)))
    |> send_resp(302, "")
  end

  get "/auth/callback" do
    token = OAuth2.Client.get_token!(client(conn), code: conn.params["code"])
    send self, token
    conn
  end

  get "/" do
    conn
    |> send_resp(200, "Hello world")
  end

  defp client(conn), do: conn.private.oauth2_client

  def put_oauth2_client(conn, _) do
    conn
    |> put_private(:oauth2_client, build_client())
  end
end
