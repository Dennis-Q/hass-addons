# Changelog

## 1.4.2

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

- Health check: a Docker `HEALTHCHECK` (Apache answers over TLS on port 443)
  replaces the obsolete `watchdog` setting. With "Watchdog" on, Supervisor
  restarts the add-on when it becomes unhealthy.
- Removed `startup` and `boot` from `config.yaml` (they were the default
  values).
- Health check requests (from 127.0.0.1 inside the container) are not logged.
- Clearer add-on description.

## 1.4.1

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

- `ban_minutes: 0` bans an IP address until the add-on restarts, and is the
  new default (was 60 minutes). If you saved the add-on options before, your
  saved value stays; set it to 0 to use the new default.

## 1.4.0

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

- Brute-force protection (on by default): an IP address with 5 failed logins
  within 10 minutes is banned for 60 minutes. Banned addresses get
  "403 Forbidden" without a password check; open tunnels stay open. New
  options `ban_enabled`, `ban_max_failures`, `ban_find_minutes`,
  `ban_minutes` and `ban_notify` (persistent notification in Home Assistant,
  off by default; the add-on now has access to the Home Assistant API for this).
- DOCS: advice on limiting access to port 443 in your router.

## 1.3.1

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

- The self-signed certificate is now a proper server certificate (not a CA
  certificate) for `homeassistant.local`. A self-signed certificate created
  by an older version is replaced once, so its fingerprint changes once more.
  Fixes the Apache warnings AH01906 and AH01909.
- Apache's server name is taken from the certificate (also with your own
  certificate), so the name check matches.
- Minimal Apache configuration: only the 14 modules the proxy needs are
  loaded (was 38, incl. load balancer, AJP, FastCGI, server-status and
  autoindex); the stock config files are no longer included.

## 1.3.0

Co-authored with [Claude Code](https://claude.com/claude-code) (Anthropic).

- AppArmor profile: the add-on now runs with its own restrictive profile
  (only the capabilities, network access and files it needs; `/ssl`
  read-only). Security rating 5 → 6.
- Watchdog: Supervisor can restart the add-on when port 443 stops answering.
  Turn on "Watchdog" on the add-on page to use it.
- Option names and descriptions in the UI (translations).
- s6-overlay services instead of a single start script: `init-httpd` prepares
  certificate, password and configuration, `httpd` runs Apache. A
  configuration error stops the add-on with a clear message in the log.
- Apache's own error log now also goes to the add-on log (it went to a file
  inside the container). Failed logins are visible there.

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
