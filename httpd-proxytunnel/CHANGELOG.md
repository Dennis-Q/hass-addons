# Changelog

## 1.2.0

Security update. Please read the breaking changes before updating.

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

### Breaking changes

- Authentication is always required: the option `enable_basic_auth` is
  removed. Set `auth_username` and `auth_password`, otherwise the add-on
  does not start. Without authentication it could be an open proxy.
- Only CONNECT (tunnel) requests are allowed by default. Set the new option
  `allow_http_proxy` to `true` to also allow plain HTTP forward proxying.
- `limit_connect_host` now matches the host exactly, and must be an IPv4
  address or host name. Before, `192.168.1.10` also allowed `192.168.1.100`.
- `auth_username` may no longer contain spaces or `:`; ports must use the
  `port[-port] [port[-port]]` syntax.
- Only `aarch64` and `amd64` are supported (`armhf`, `armv7` and `i386` are no
  longer supported by Home Assistant).
- The self-signed certificate is now kept in the add-on data folder, so its
  fingerprint changes once with this update and then stays the same.

### Fixes and improvements

- Fixed: with authentication off, `limit_connect_host` had no effect and any
  destination was allowed.
- Self-signed certificate is only regenerated when it has expired or does not
  match its key; its SHA-256 fingerprint is logged at every start.
- Passwords are stored as bcrypt instead of MD5; a warning is logged when the
  password appears in a known data breach.
- The Apache configuration is generated from validated options instead of
  being edited with `sed`; it is checked before Apache starts.
- TLS settings follow the Mozilla "intermediate" profile (TLS 1.2 + 1.3,
  session tickets off); fixed the SSL session cache path; TRACE disabled.
- `/ssl` is mounted read-only; the unused plain HTTP listener is off.
- Base image updated to `ghcr.io/hassio-addons/base` 21.0.10 (Alpine 3.24), set in
  the Dockerfile (no `build.yaml`, which Supervisor no longer recommends).
- Removed unused `init_commands` code.

## 1.1.0

- Replace `config.json` with `config.yaml`, `init: false`
- Dockerfile and `run.sh` updated for newer Home Assistant releases

## 1.0.1

- Update options schema for passwords

## 1.0.0

- Initial release
