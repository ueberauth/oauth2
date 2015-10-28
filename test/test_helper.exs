ExUnit.start

provider_opts = Application.get_env(:oauth2, ProviderRouter)
consumer_opts = Application.get_env(:oauth2, ConsumerRouter)

Plug.Adapters.Cowboy.http ProviderRouter, [], provider_opts
Plug.Adapters.Cowboy.http ConsumerRouter, [], consumer_opts
Application.ensure_all_started(:bypass)
