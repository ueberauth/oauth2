defmodule ProviderRouter do
  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug :match
  plug :dispatch

  get "/oauth/authorize" do
    redirect_uri = conn.params["redirect_uri"]
    conn
    |> put_resp_header("location", redirect_uri <> "?" <> "code=1234")
    |> send_resp(302, "")
  end

  post "/oauth/token" do
    token = %{expires_in: 3600, access_token: "abc123", token_type: "bearer"}
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(token))
  end

  get "/api/success.json" do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, "{\"data\": \"success!\"}")
  end

  get "/api/error.json" do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(406, "{\"error\": \"oh noes!\"}")
  end
end
