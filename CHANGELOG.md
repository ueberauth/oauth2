# Changelog

## v0.5.0 (2015-11-03)

### Improvements

* You can now request a refresh token with `OAuth2.AccessToken.refresh`. The `!` alternative is also available.
* Added `Bypass` for improved testability.
* `Plug` is no longer a direct dependency. It is only included as a test dependency through the `Bypass` library.
* `OAuth2.AccessToken` now supports `DELETE` requests with `delete` and `delete!`
* More tests!

### Bug Fixes

* Params are no longer sent in both the body and as a query string for `POST` requests with `OAuth2.Client.get_token`
* Responses will no longer be parsed automatically if the `content-type` is not supported by this lib. Registering custom parsers is a future goal for this library.
* Errors are now properly raised when they occur.

### Backwards Incompatible Changes

* `OAuth2.new/1` has been removed. Use `OAuth2.Client.new/1` instead.

Diff: https://github.com/scrogson/oauth2/compare/v0.4.0...v0.5.0

## v0.4.0 (2015-10-27)

### Additions/Improvements

* `OAuth2.AccessToken` now supports: `post`, `post!`, `put`, `put!`, `patch`, and `patch!`.
* Better documentation
* Test coverage improved

### Bug fixes

* Empty response bodies are no longer decoded

### Breaking changes

* `OAuth2.AccessToken.get!/4` now returns `OAuth2.Response{}` instead of just the parsed body.

### Aknowledgements

Thanks to @meatherly, @dejanstrbac, and @optikfluffel for their contributions!

Diff: https://github.com/scrogson/oauth2/compare/v0.3.0...v0.4.0

## v0.3.0 (2015-08-19)

Bump `Plug` dependency to `1.0`.

Diff: https://github.com/scrogson/oauth2/compare/v0.2.0...v0.3.0


## v0.2.0 (2015-07-13)

- `:erlang.now` was replaced with `:os.timestamp` for compatibility with Erlang 18
- You can now pass options to the `HTTPoison` library with `OAuth2.Client.get_token/4` and `OAuth2.Client.get_token!/4`

Diff: https://github.com/scrogson/oauth2/compare/v0.1.1...v0.2.0


## v0.1.1 (2015-04-18)

- Remove compilation warnings.
- Fix `request_body` function for `ClientCredentials`

Diff: https://github.com/scrogson/oauth2/compare/v0.1.0...v0.1.1


## v0.1.0 (2015-04-14)

This release bring breaking changes and more documentation.

Please see the [README](https://github.com/scrogson/oauth2/blob/v0.1.0/README.md) or [Hex Docs](http://hexdocs.pm/oauth2/0.1.0) for more details.

Diff: https://github.com/scrogson/oauth2/compare/v0.0.5...v0.1.0


## v0.0.5 (2015-04-11)

- Handles Facebooks `expires` key for Access Tokens.
- Ensure the token type defaults to 'Bearer' when it is not present.

Diff: https://github.com/scrogson/oauth2/compare/0.0.3...v0.0.5


## v0.0.3 (2015-01-12)

- Relax version requirements for Poison.

## v0.0.2 (2015-01-10)

This release brings Password and Client Credentials strategies.

http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.3
http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.4

## v0.0.1 (2014-12-07)

Initial release.

This initial release includes a functional authorization code strategy: http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.1
