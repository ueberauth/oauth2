Application.ensure_all_started(:bypass)
Application.ensure_all_started(:hackney)
Application.put_env(:oauth2, :warn_missing_serializer, false)
ExUnit.start()
