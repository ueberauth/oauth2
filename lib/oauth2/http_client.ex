defmodule OAuth2.HTTPClient do
  @callback request(
              method :: atom(),
              url :: binary(),
              headers :: list(),
              body :: any(),
              req_opts :: any()
            ) ::
              {:ok, any()} | {:ok, integer(), list(), any()} | {:error, any()}

  @callback body(ref :: any()) :: {:ok, binary()} | {:error, any()}
end
