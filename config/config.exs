use Mix.Config

config :logger, level: :info

config :oauth2,
  client_id: "0bee1126b1a1381d9cab60bcd52349484451808a", # first commit sha of this library
  client_secret: "f715d64092fe81c396ac383e97f8a7eca40e7c89", #second commit sha
  redirect_uri: "http://example.com/auth/callback",
  serializers: %{"application/json" => Poison}
