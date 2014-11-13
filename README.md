OAuth2
======

> OAuth2 Library for Elixir

## API

This is still a work in progress. But here's what I'm thinking so far:

#### Authorization Code Flow (AuthCode Strategy)

```elixir
alias OAuth2.Strategy.AuthCode

# Initialize the strategy with your client_id, client_secret, and site.
strategy = AuthCode.new([
  client_id: "client_id",
  client_secret: "abc123",
  site: "https://auth.example.com"
])

# Generate the authorization URL and redirect the user to the provider.
AuthCode.authorize_url(strategy, %{redirect_uri: "https://example.com/auth/callback"})
# => "https://auth.example.com/oauth/authorize?client_id=client_id&redirect_uri=https%3A%2F%2Fexample.com%2Fauth%2Fcallback&response_type=code"

# Use the authorization code returned from the provider to obtain an access token.
token = AuthCode.get_token!(strategy, %{code: "someauthcode", redirect_uri: "https://example.com/auth/callback"})

# Use the access token to make a request for resources
resource = OAuth2.AccessToken.get!(token, "/api/resource")
```
