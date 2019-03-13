defmodule OAuth2.TestHelpers do

  import Plug.Conn
  import ExUnit.Assertions

  def bypass_server(%Bypass{port: port}) do
    "http://localhost:#{port}"
  end

  def bypass(server, method, path, fun) do
    bypass(server, method, path, [], fun)
  end
  def bypass(server, method, path, opts, fun) do
    {token, opts}   = Keyword.pop(opts, :token, nil)
    {accept, _opts} = Keyword.pop(opts, :accept, "json")

    Bypass.expect server, fn conn ->
      conn = parse_req_body(conn)

      assert conn.method == method
      assert conn.request_path == path
      assert_accepts(conn, accept)
      assert_token(conn, token)

      fun.(conn)
    end
  end

  def unix_now do
    {mega, sec, _micro} = :os.timestamp
    (mega * 1_000_000) + sec
  end

  defp parse_req_body(conn) do
    opts = [parsers: [:urlencoded, :json],
            pass: ["*/*"],
            json_decoder: Jason]
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  defp assert_accepts(conn, accept) do
    mime =
      case accept do
        "json" -> "application/json"
        _      -> accept
      end
    assert get_req_header(conn, "accept") == [mime]
  end

  defp assert_token(_conn, nil), do: :ok
  defp assert_token(conn, token) do
    assert get_req_header(conn, "authorization") == ["Bearer #{token.access_token}"]
  end

  def json(conn, status, body \\ []) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  def build_client(opts \\ []) do
    default_client_opts()
    |> Keyword.merge(opts)
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def tokenize_client(opts \\ [], %OAuth2.Client{} = client) do
    token =
      default_token_opts()
      |> Keyword.merge(opts)
      |> stringify_keys()
      |> OAuth2.AccessToken.new()
    %{client | token: token}
  end

  def async_client(%{request_opts: req_opts} = client) do
    async_opts = [async: true, stream_to: self()]
    %{client | request_opts: Keyword.merge(req_opts, async_opts)}
  end

  defp get_config(key) do
    Application.get_env(:oauth2, key)
  end

  defp default_client_opts do
    [client_id: get_config(:client_id),
     client_secret: get_config(:client_secret),
     redirect_uri: get_config(:redirect_uri),
     request_opts: get_config(:request_opts)]
  end

  defp default_token_opts do
    [access_token: "abcdefgh",
     expires_at: OAuth2.Util.unix_now + 600,
     token_type: "Bearer"]
  end

  defp stringify_keys(dict) do
    dict
    |> Enum.map(fn {k,v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
