# docker-csc2fa-proxy

> Cisco Secure Client (2FA) + Proxy

## Configurations

Secrets:

```shell
echo vpn.server.name >server_name.txt
host $(cat server_name.txt) | grep "has address" | awk '{print $NF}' >server_ip.txt
echo username >username.txt
echo password >password.txt
```

Optional variables can be defined in the `proxy.env` file:

```
# Sleep time to wait for ready to enter the server name (default: 10s).
SLEEP_FOR_SERVER_NAME=15s

# Sleep time to wait for ready to enter the username (default: 0s).
SLEEP_FOR_USERNAME=1s

# Sleep time to wait for ready to enter the password (default: 0s).
SLEEP_FOR_PASSWORD=1s

# Launch a SOCKS5 proxy using an SSH dynamic port forwarding connection between the container and
# the specified remote host instead of launching a Privoxy server.
SOCKS5_REMOTE_HOST=remote.host
SOCKS5_REMOTE_USER=user
```

## 2FA

Install an authenticator into your device:

* Microsoft Authenticator (tested)
* Google Authenticator (**NOT TESTED**)

## Cisco Secure Client

Copy an archive file of [Cisco Secure Client 5] in this folder as `package.tar.gz`.  It must
contains the following scripts:

* `<dir>/vpn/vpn_install.sh`
* `<dir>/dart/dart_install.sh`

See [setup.sh](./setup.sh) for details.

## How to use

Create a container for the `proxy` service:

```shell
# $USER/csc2fa-http-proxy image will be created automatically if it doesn't exist.
# `docker compose build` builds it manually.
# See compose.yaml for details.
docker compose up -d
```

The container starts an [Openbox] session.  The screen can be accessible by using a modern web
browser via [noVNC] and [x11vnc].

Open `http://localhost:5980/vnc_auto.html` in your web browser.  You can see that [xdotool] will
enter texts on the Cisco Secure Client window and dialog automatically instead of you.  Wait a
moment for PIN code to be shown.

Finally, enter the PIN code on the authenticator and close the dialog on the noVNC screen after the
authentication finishes successfully.

One of the following proxy running in the container proxies requests to servers in the private network:

* [Privoxy]
* [SOCKS5] using an SSH dynamic port forwarding

The either can be accessible with `http://localhost:8118`.

## Technical Notes

`LocalLanAccess` must be enabled in `/opt/cisco/secureclient/vpn/.anyconnect_global` in order to
allow accesses from outside the container.

Properties of the `Cisco Secure Client` window:

```
WM_CLASS(STRING) = "com.cisco.secureclient.gui", "Com.cisco.secureclient.gui"
WM_ICON_NAME(STRING) = "Cisco Secure Client"
_NET_WM_ICON_NAME(UTF8_STRING) = "Cisco Secure Client"
WM_NAME(STRING) = "Cisco Secure Client"
_NET_WM_NAME(UTF8_STRING) = "Cisco Secure Client"
```

Properties of the `libwebkit2gtk` popup window:

```
WM_CLASS(STRING) = "Cisco Secure Client", "Cisco Secure Client"
WM_ICON_NAME(STRING) = "Cisco Secure Client - Login"
_NET_WM_ICON_NAME(UTF8_STRING) = "Cisco Secure Client - Login"
WM_NAME(STRING) = "Cisco Secure Client - Login"
_NET_WM_NAME(UTF8_STRING) = "Cisco Secure Client - Login"
```

## Links

If you are looking for an L2TP IPsec-VPN container, see
[masnagam/docker-l2tp-ipsec-http-proxy](https://github.com/masnagam/docker-l2tp-ipsec-http-proxy).

## License

[MIT](./LICENSE)

[Cisco Secure Client 5]: https://www.cisco.com/c/en/us/support/security/secure-client-5/model.html
[Openbox]: https://openbox.org/
[noVNC]: https://novnc.com/info.html
[x11vnc]: https://en.wikipedia.org/wiki/X11vnc
[xdotool]: https://github.com/jordansissel/xdotool
[Privoxy]: https://www.privoxy.org/
[SOCKS5]: https://en.wikipedia.org/wiki/SOCKS
