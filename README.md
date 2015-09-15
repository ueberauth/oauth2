OAuth2
======

[![Build Status](https://travis-ci.org/scrogson/oauth2.svg?branch=master)](https://travis-ci.org/scrogson/oauth2)
[![Coverage Status](https://coveralls.io/repos/scrogson/oauth2/badge.svg?branch=master&service=github)](https://coveralls.io/github/scrogson/oauth2?branch=master)

> OAuth2 Library for Elixir

## Install

```elixir
# mix.exs

def application do
  # Add the application to your list of applications.
  # This will ensure that it will be included in a release.
  [applications: [:logger, :oauth2]]
end

defp deps do
  # Add the dependency
  [{:oauth2, "~> 0.3"}]
end
```

## API

Current implemented strategies:

- Authorization Code
- Password
- Client Credentials

### Authorization Code Flow (AuthCode Strategy)

```elixir
# Initialize a client with client_id, client_secret, site, and redirect_uri.
# The strategy option is optional as it defaults to `OAuth2.Strategy.AuthCode`.

client = OAuth2.new([
  strategy: OAuth2.Strategy.AuthCode, #default
  client_id: "client_id",
  client_secret: "abc123",
  site: "https://auth.example.com",
  redirect_uri: "https://example.com/auth/callback"
])

# Generate the authorization URL and redirect the user to the provider.
OAuth2.Client.authorize_url(client)
# => "https://auth.example.com/oauth/authorize?client_id=client_id&redirect_uri=https%3A%2F%2Fexample.com%2Fauth%2Fcallback&response_type=code"

# Use the authorization code returned from the provider to obtain an access token.
token = OAuth2.Client.get_token!(client, code: "someauthcode")

# You can also use `OAuth2.Client.put_param/3` to update the client's `params`
# field. Example:
# token =
#   client
#   |> OAuth2.Client.put_param(:code, "someauthcode")
#   |> OAuth2.Client.get_token!()

# Use the access token to make a request for resources
resource = OAuth2.AccessToken.get!(token, "/api/resource")
```

### Write Your Own Strategy

Here's an example strategy for GitHub:

```elixir

defmodule GitHub do
  use OAuth2.Strategy

  # Public API

  def new do
    OAuth2.new([
      strategy: __MODULE__,
      client_id: "abc123",
      client_secret: "abcdefg",
      redirect_uri: "http://myapp.com/auth/callback",
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  def authorize_url!(params \\ []) do
    new()
    |> put_param(:scope, "user,public_repo")
    |> OAuth2.Client.authorize_url!(params)
  end

  # you can pass options to the underlying http library via `options` parameter
  def get_token!(params \\ [], headers \\ [], options \\ []) do
    OAuth2.Client.get_token!(new(), params, headers, options)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
```

Here's how you'd use the example GitHub strategy:

Generate the authorize URL and redirect the client for authorization.

```elixir
GitHub.authorize_url!
```

Capture the `code` in your callback route on your server and use it to obtain an access token.

```elixir
token = GitHub.get_token!(code: code)
```

Use the access token to access desired resources.

```elixir
user = OAuth2.AccessToken.get!(token, "/user")
```

## Examples

- [Authenticate with Github (OAuth2/Phoenix)](https://github.com/scrogson/oauth2_example)

## License

The MIT License (MIT)

Copyright (c) 2015 Sonny Scroggin

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
