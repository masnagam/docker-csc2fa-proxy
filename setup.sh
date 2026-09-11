set -eu

PROGNAME=$(basename $0)
BASEDIR=$(cd $(dirname $0); pwd)
PACKAGE=$BASEDIR/package.tar.gz

export DEBIAN_FRONTEND=noninteractive

apt-get update

# for TZ
apt-get install -y --no-install-recommends tzdata

# tools for debugging purposes
apt-get install -y dnsutils iproute2 iputils-ping iputils-tracepath tcpdump

# SOCKS5 proxy
apt-get install -y --no-install-recommends autossh openssh-client sshpass

# http proxy
apt-get install -y --no-install-recommends privoxy

# port forwarding
apt-get install -y --no-install-recommends socat

# x11 window manager
apt-get install -y --no-install-recommends gosu openbox python3-xdg xvfb xterm

# vnc
apt-get install -y --no-install-recommends novnc x11vnc

# for automatic login
apt-get install -y --no-install-recommends xdotool at-spi2-core python3-pyatspi

# for debugging purposes
apt-get install -y --no-install-recommends curl

# cisco secure client

# https://www.cisco.com/c/en/us/support/docs/security/secure-client-5/223124-configure-secure-client-vpn-for-use-in.html
apt-get install -y net-tools iptables
# additional packages required
apt-get install -y --no-install-recommends libglib2.0-0t64 libgtk-3-0t64 libwebkit2gtk-4.1-0 libxml2

# extracted files will be removed in the cleanup phase
if tar tzf "$PACKAGE" | grep -q 'cisco-secure-client-vpn_.*\.deb$'; then
    DEB_DIR=$(mktemp -d /tmp/cisco-secure-client.XXXXXX)
    tar xf "$PACKAGE" -C "$DEB_DIR"

    VPN_DEB=$(find "$DEB_DIR" -type f -name 'cisco-secure-client-vpn_*.deb' -print -quit)
    DART_DEB=$(find "$DEB_DIR" -type f -name 'cisco-secure-client-dart_*.deb' -print -quit)
    if [ -z "$VPN_DEB" ] || [ -z "$DART_DEB" ]; then
        echo "The Cisco Secure Client package must contain VPN and DART deb files." >&2
        exit 1
    fi

    apt-get install -y "$VPN_DEB" "$DART_DEB"
else
    tar xf "$PACKAGE" -C /tmp --strip-components=1

    sed -i 's|echo "Error: systemd required.*$|echo "QUICK-HACK: systemd" >> /tmp/${LOGFNAME}|' /tmp/vpn/vpn_install.sh
    (cd /tmp/vpn; yes | ./vpn_install.sh)

    mkdir -p /etc/dbus-1/system.d/
    mkdir -p /usr/share/dbus-1/system-services/
    (cd /tmp/dart; yes | ./dart_install.sh)
fi

# cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/tmp/*
rm -rf /tmp/*
