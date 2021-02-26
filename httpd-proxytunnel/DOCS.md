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
```

**Note**: _This is just an example, don't copy and past it! Create your own!_ 

### Option: `use_own_ssl_cert`
Enables/disables the use of your own SSL-certificate. When set to `true`, it will use the provided SSL-certificates set in `certfile` and `keyfile`. If set to `false` it will create new (self-signed) SSL-certificates at the start of the addon.

**Note:** _The latest versions of the 'proxytunnel' require the '-z' or '--no-check-certificate' option to prevent a certificate verification error._

### Option: `certfile`
The certificate file to use for SSL. Only used when `use_own_ssl_cert` is set to `true`.

**Note**: _The file MUST be stored in `/ssl/`._

### Option: `keyfile`
The private key file to use for SSL. Only used when `use_own_ssl_cert` is set to `true`.

**Note**: _The file MUST be stored in `/ssl/`._

### Option: `enable_basic_auth`
Option to enable Basic HTTP Authentication (htpasswd). It is strongly advised to keep this enabled as it adds an additional layer of security.
Options `auth_username` and `auth_password` are required when enabled. You can use the credentials using the '-P' flag of proxytunnel. 

**Note**: _It is NOT recommended setting this to `false`._

### Option: `auth_username`
The username which will be required to use the proxy. This field is only used when `enabled_basic_auth` is set to `true`.

### Option: `auth_password`
The password which will be required to use the proxy. This field is only used when `enabled_basic_auth` is set to `true`.

### Option: `enable_limit_connect`
Enables/disables limiting connectivity to a specific port or host. When set to `false` this will use the default 'AllowConnect' ports (currently 443 563) and any destination host is allowed. When set to `true` the result depends on what is entered in `limit_allowconnect_port` and `limit_connect_host`.


### Option: `limit_allowconnect_port`
The AllowCONNECT port entered here is the one put into the httpd-configuration file. Please check the mod_proxy_connect documentation for more information. Syntax: 'port[-port] [port[-port]] ...'.

**Note**: _If you want to connect to a host using SSH/proxytunnel, it is required to enter `22` here (which is the default SSH port)._

### Option: `limit_connect_host`
This option can limit the host you would like to be able to connect to. Currently it is using the '<Proxy [VALUE]>' option to limit it. You can enter an IP-address here. If the value is empty, it will allow to connect to any destination.

&nbsp;
## Security
This addon was built with security in mind. Multiple steps were taken to make it as safe as possible. Some examples: limiting the CipherSuits to 'HIGH', limiting SSL protocols to only TLSv1.2 and TLSv1.3. Other functionality that was implemented to improve security are the option to enable username/password authentication, as well as limiting the destination port and host. 

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
	ProxyCommand proxytunnel -z -E -p myproxy.athome.nl:443 -P username:password -d mybox.athome.nl:443

```

For the details on the flags, please check the [proxytunnel]  documentation.


&nbsp;
## Port forwarding
Please ensure to enable port-forwarding to your home assistant installation to the port configured with this addon. This will allow you to connect to the system from the public internet.

&nbsp;
## Changelog & Releases
v1.0.0 - Initial Release


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
