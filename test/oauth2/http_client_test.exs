defmodule OAuth2.HTTPClientTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias OAuth2.Client

  import OAuth2.TestHelpers

  defmodule PureHackney do
    @behaviour OAuth2.HttpClient

    @impl OAuth2.HttpClient
    def request(opts) do
      hackney_opts =
        opts
        |> Keyword.get(:opts)
        |> Keyword.get(:adapter, [])

      method = Keyword.get(opts, :method)
      url = Keyword.get(opts, :url)
      headers = Keyword.get(opts, :headers)
      body = Keyword.get(opts, :body)

      with {:ok, status, headers, body_ref} <-
             :hackney.request(method, url, headers, body, hackney_opts),
           {:ok, body} <- :hackney.body(body_ref) do
        {:ok, %{body: body, status: status, headers: headers}}
      end
    end
  end

  setup do
    Application.delete_env(:oauth2, :http_client)
    server = Bypass.open()

    %{server: server}
  end

  test "http client can be passed to client", %{server: server} do
    client =
      build_client(
        site: bypass_server(server),
        http_client: Tesla
      )
      |> tokenize_client()

    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = Client.get(client, "/api/user/1", [])
    assert result.status_code == 200
    assert result.body["id"] == 1
  end

  test "http client can be set in config", %{server: server} do
    Application.put_env(:oauth2, :http_client, Tesla)

    client =
      build_client(
        site: bypass_server(server),
        http_client: nil
      )
      |> tokenize_client()

    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = Client.get(client, "/api/user/1", [])
    assert result.status_code == 200
    assert result.body["id"] == 1
  end

  test "Tesla client can be passed to the request/2" do
    client =
      build_client(
        site: "https://foo.bar",
        http_client: {Tesla.client([], Tesla.Mock), Tesla}
      )

    Tesla.Mock.mock(fn _env -> %Tesla.Env{status: 200, body: "{}"} end)

    {:ok, result} = Client.get(client, "/api/user/1", [])
    assert result.status_code == 200
    assert result.body == %{}
  end

  test "user can define their own http_client", %{server: server} do
    client =
      build_client(
        site: bypass_server(server),
        http_client: PureHackney
      )
      |> tokenize_client()

    bypass(server, "GET", "/api/user/1", [token: client.token], fn conn ->
      json(conn, 200, %{id: 1})
    end)

    {:ok, result} = Client.get(client, "/api/user/1", [])
    assert result.status_code == 200
    assert result.body["id"] == 1
  end
end
