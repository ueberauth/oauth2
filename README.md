OAuth2
======

> OAuth2 Library for Elixir

## API

Current implemented strategies:

- Authorization Code
- Password
- Client Credentials

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
token = AuthCode.get_token!(strategy, "someauthcode", %{redirect_uri: "https://example.com/auth/callback"})

# Use the access token to make a request for resources
resource = OAuth2.AccessToken.get!(token, "/api/resource")
```

## Examples

- [Authenticate with Github (OAuth2/Phoenix)](https://github.com/scrogson/oauth2_example)

## License

The MIT License (MIT)

Copyright (c) 2014 Sonny Scroggin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
