defmodule OAuth2.Util do
  @moduledoc false

  def unix_now do
    {mega, sec, _micro} = :os.timestamp
    (mega * 1_000_000) + sec
  end

  def content_type(headers) do
    case get_content_type(headers) do
      {_, content_type} ->
        content_type
        |> remove_params
        |> parse_content_type
      nil ->
        "application/json"
    end
  end

  defp remove_params(binary) do
    [content_type | _] = String.split(binary, ";")
    content_type
  end

  defp parse_content_type(content_type) do
    case String.split(content_type, "/") do
      [type, subtype] ->
        type <> "/" <> subtype
      [bad_type] ->
        raise OAuth2.Error, reason: "bad content-type: #{bad_type}"
    end
  end

  defp get_content_type(headers) do
    List.keyfind(headers, "content-type", 0)
  end
end
