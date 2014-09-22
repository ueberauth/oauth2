defmodule OAuth2.Util do
  def unix_now do
    {mega, sec, _micro} = :erlang.now
    (mega * 1_000_000) + sec
  end
end
