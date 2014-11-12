defmodule OAuth2.Util do

  def unix_now do
    {mega, sec, _micro} = :erlang.now
    (mega * 1_000_000) + sec
  end

  def content_type(headers) do
    case List.keyfind(headers, "Content-Type", 0) do
      {"Content-Type", content_type} ->
        case Plug.Conn.Utils.content_type(content_type) do
          {:ok, type, subtype, _headers} ->
            type <> "/" <> subtype
          :error ->
            "application/json"
        end
      nil ->
        "application/json"
    end
  end
end
