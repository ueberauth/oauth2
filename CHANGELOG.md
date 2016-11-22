# Changelog

## v0.8.2 (2016-11-22)

### Bug Fixes

* Fixed an issue in handling non-standard `expires` key in access token
  requests.

## v0.8.1 (2016-11-18)

### Improvements

* Added the ability to debug responses from the provider.

### Bug Fixes

* Fixed regression in handling `text/plain` content-type for tokens in #74

## v0.8.0 (2016-10-05)

### Improvements

* Added `OAuth2.Client.basic_auth/1` convenience function.

### Bug Fixes

* Fixed broken `RefreshToken` strategy reported in #66
* Fixed an issue where checking the `content-type` was defaulting to
  `application/json` causing Poison to explode.

## v0.7.0 (2016-08-16)

### Improvements
* Add support for custom serializers based on MIME types.
* Remove dependency on `HTTPoison` in favor of using `hackney` directly.
* Remove dependency on `mimetype_parser`.
* `Poison` is now only a `test` dependency.

### Bug Fixes
* `expires_in` values that are returned as strings are now properly parsed into integers for `expires_at`.

### Backward Incompatible Changes

Prior to version `v0.7.0` `OAuth2.Client` was primarily used for the purpose
of interfacing with the OAuth server to retrieve a token. `OAuth2.Token` was
then responsible for using that token to make authenticated requests.

In `v0.7.0` this interface has been refactored so that an `OAuth2.Client` struct
now references an `OAuth2.Token` directly and many of the action methods have
been moved so that they are called on `OAuth2.Client`, with an instance of the
client struct as their first argument.

Please consult the [README](https://github.com/scrogson/oauth2/blob/v0.7.0/README.md) for an example of general usage to retrieve a token and make a request.

The following methods have been moved and adjusted so that they take a `OAuth2.Client.t` which contains a token, rather than a token directly:

* `OAuth2.AccessToken.get` -> `OAuth2.Client.get`
* `OAuth2.AccessToken.get!` -> `OAuth2.Client.get!`
* `OAuth2.AccessToken.put` -> `OAuth2.Client.put`
* `OAuth2.AccessToken.put!` -> `OAuth2.Client.put!`
* `OAuth2.AccessToken.patch` -> `OAuth2.Client.patch`
* `OAuth2.AccessToken.patch!` -> `OAuth2.Client.patch!`
* `OAuth2.AccessToken.post` -> `OAuth2.Client.post`
* `OAuth2.AccessToken.post!` -> `OAuth2.Client.post!`
* `OAuth2.AccessToken.delete` -> `OAuth2.Client.delete`
* `OAuth2.AccessToken.delete!` -> `OAuth2.Client.delete!`
* `OAuth2.AccessToken.refresh` -> `OAuth2.Client.refresh_token`
* `OAuth2.AccessToken.refresh!` -> `OAuth2.Client.refresh_token!`

Additionally, the following methods have been moved to `OAuth2.Request`

* `OAuth2.AccessToken.request` -> `OAuth2.Request.request`
* `OAuth2.AccessToken.request!` -> `OAuth2.Request.request!`

Diff: https://github.com/scrogson/oauth2/compare/v0.6.0...v0.7.0

## v0.6.0 (2016-06-24)

### Improvements
* Use Poison ~> 2.0
* Reset client headers after fetching the token

### Bug Fixes
* Fix up auth code flow to match the RFC

Diff: https://github.com/scrogson/oauth2/compare/v0.5.0...v0.6.0

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

