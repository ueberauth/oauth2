defmodule OAuth2.Error do
  @moduledoc false

  @type t :: %__MODULE__{
          reason: binary
        }

  defexception [:reason]

  def message(%__MODULE__{reason: :econnrefused}), do: "Connection refused"
  def message(%__MODULE__{reason: reason}) when is_binary(reason), do: reason
  def message(%__MODULE__{reason: reason}), do: inspect(reason)
end
