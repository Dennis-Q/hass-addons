# Home Assistant Custom Addon: httpd-proxytunnel

This enables you to run an httpd-proxytunnel service within home-assistant using apache2 and the mod_proxy module. 

**NOTE** This addon was created for personal use and might not (yet) fit to your needs. It allows connectivity from restricted networks (like your company network) to your private home network over HTTPS. Since HTTPS is encrypted using SSL/TLS, it is usually not blocked by Firewalls or DPI (Deep Packet Inspection). The combination of this addon with the 'proxytunnel' client, allows you to SSH into your home server. 'proxytunnel' is my favorite client to use with this addon.

## Installation

1. Add this repository `https://github.com/Dennis-Q/hass-addons` to your Home Assistant installation
1. Install the addon 'httpd-proxytunnel'.
1. Enjoy :)

&nbsp;
## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
use_own_ssl_cert: false
certfile: /ssl/httpd-proxytunnel/fullchain.pem
keyfile: /ssl/httpd-proxytunnel/privkey.pem
enable_basic_auth: true
auth_username: VeryStrongUserName
auth_password: EvenStr0ngerPassw0rd!
enable_limit_connect: true
limit_allowconnect_port: 22
limit_connect_host: 192.168.1.100
allow_http_proxy: false
```

**Note**: _This is just an example, don't copy and past it! Create your own!_ 

### Option: `use_own_ssl_cert`
Enables/disables the use of your own SSL-certificate. When set to `true`, it will use the provided SSL-certificates set in `certfile` and `keyfile`. If set to `false` the add-on creates a self-signed certificate (valid for 10 years) in its own data folder. It keeps using that certificate across restarts and only creates a new one when it has expired or does not match its key.

The add-on log shows the SHA-256 fingerprint of the certificate at every start. Write it down: if it changes while you did not expect a new certificate, something is wrong.

**Note:** _With a self-signed certificate, 'proxytunnel' needs the '-z' or '--no-check-certificate' option. That skips the certificate check, so compare the fingerprint when in doubt._

### Option: `certfile`
The certificate file to use for SSL. Only used when `use_own_ssl_cert` is set to `true`.

**Note**: _The file MUST be stored in `/ssl/`._

### Option: `keyfile`
The private key file to use for SSL. Only used when `use_own_ssl_cert` is set to `true`.

**Note**: _The file MUST be stored in `/ssl/`._

### Option: `enable_basic_auth`
Option to enable Basic HTTP Authentication (htpasswd). It is strongly advised to keep this enabled as it adds an additional layer of security.
Options `auth_username` and `auth_password` are required when enabled. You can use the credentials using the '-P' flag of proxytunnel. 

**Note**: _It is NOT recommended setting this to `false`. When it is `false`, `enable_limit_connect` must be `true` and `limit_connect_host` must be set, otherwise the add-on refuses to start (it would be an open proxy)._

### Option: `auth_username`
The username which will be required to use the proxy. This field is only used when `enable_basic_auth` is set to `true`. It may not contain spaces or `:`.

### Option: `auth_password`
The password which will be required to use the proxy. This field is only used when `enable_basic_auth` is set to `true`. It is stored as a bcrypt hash. The log shows a warning when the password appears in a known data breach (Have I Been Pwned).

### Option: `enable_limit_connect`
Enables/disables limiting connectivity to a specific port or host. When set to `false` this will use the default 'AllowConnect' ports (currently 443 563) and any destination host is allowed. When set to `true` the result depends on what is entered in `limit_allowconnect_port` and `limit_connect_host`.


### Option: `limit_allowconnect_port`
The AllowCONNECT port entered here is the one put into the httpd-configuration file. Please check the mod_proxy_connect documentation for more information. Syntax: 'port[-port] [port[-port]] ...'.

**Note**: _If you want to connect to a host using SSH/proxytunnel, it is required to enter `22` here (which is the default SSH port)._

### Option: `limit_connect_host`
This option limits the proxy to one destination host. Enter an IPv4 address or a host name; it must match exactly (`192.168.1.10` does not allow `192.168.1.100`). Clients must use the same form: if you enter an IP address, connect to the IP address, not to a name that points to it. If the value is empty, any destination is allowed.

### Option: `allow_http_proxy`
When `false` (default) only CONNECT requests (tunnels, as used by proxytunnel) are allowed. When `true` the add-on also works as a plain HTTP forward proxy for the same users and destinations. Leave it `false` unless you need it.

&nbsp;
## Security
This addon was built with security in mind. Multiple steps were taken to make it as safe as possible. Some examples: TLS 1.2 and 1.3 only with the Mozilla "intermediate" cipher list, only CONNECT requests by default, username/password authentication (bcrypt), exact destination host and port limits, and a refusal to start as an open proxy. The `/ssl` folder is mounted read-only. 

In case you do have any suggestions, tips or remarks for improvement, please do contact me. :)

&nbsp;
## proxytunnel (client)
To make this addon useful, you might want to use a client which helps using it. Of course there are multiple tools to make use of it, I think the most useful one is 'proxytunnel'. [proxytunnel] is a great piece of software which helps to make use of this addon seamlessly with SSH.


### Install
You can install proxytunnel several ways, e.g. download precompiled binary or with software distribution tools like 'apt' and 'yum'. Please check the proxytunnel website for more details.


### Configuration
Using proxytunnel is easy, what you can do is add the following into your `~/.ssh/config`. More details again in the [proxytunnel]  documentation but this might help you to get it up and running quickly.

```
Host foobar
	ProtocolKeepAlives 30
	ProxyCommand proxytunnel -z -E -p myproxy.athome.nl:443 -P username:password -d mybox.athome.nl:22

```

For the details on the flags, please check the [proxytunnel]  documentation.


&nbsp;
## Port forwarding
Please ensure to enable port-forwarding to your home assistant installation to the port configured with this addon. This will allow you to connect to the system from the public internet.

&nbsp;
## Changelog & Releases
See [CHANGELOG.md](CHANGELOG.md).


&nbsp;
## Authors & contributors
The original setup of this repository is by Dennis-Q.

Special thanks to [Mik3yZ] for the support in creating & testing this addon and of course the logo!\
Thanks to [FaserF] for his apache2 Add-on which was used as a base for this addon.


&nbsp;
## License

MIT License

Copyright (c) 2021 [Dennis-Q]

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

[proxytunnel]: https://github.com/proxytunnel/proxytunnel
[Dennis-Q]: https://github.com/Dennis-Q
[Mik3yZ]: https://github.com/Mik3yZ
[FaserF]: https://github.com/FaserF/hassio-addons/tree/master/apache2
