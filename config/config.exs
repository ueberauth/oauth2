use Mix.Config

config :logger, level: :debug

config :oauth2,
  # first commit sha of this library
  client_id: "0bee1126b1a1381d9cab60bcd52349484451808a",
  # second commit sha
  client_secret: "f715d64092fe81c396ac383e97f8a7eca40e7c89",
  redirect_uri: "http://example.com/auth/callback",
  http_client: OAuth2.HTTPClient.Hackney,
  request_opts: []
