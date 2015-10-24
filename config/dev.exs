use Mix.Config

provider_router_port = 4999
consumer_router_port = 4998

config :oauth2,
  client_id: "client_id",
  client_secret: "client_secret",
  site: "http://localhost:#{provider_router_port}",
  redirect_uri: "http://localhost:#{consumer_router_port}/auth/callback"

config :oauth2, ProviderRouter,
  port: provider_router_port

config :oauth2, ConsumerRouter,
  port: consumer_router_port
