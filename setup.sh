set -eu

PROGNAME=$(basename $0)
BASEDIR=$(cd $(dirname $0); pwd)

export DEBIAN_FRONTEND=noninteractive

apt-get update

# for TZ
apt-get install -y --no-install-recommends tzdata

# tools for debugging purposes
apt-get install -y dnsutils iproute2 iputils-ping iputils-tracepath tcpdump

# SOCKS5 proxy
apt-get install -y --no-install-recommends autossh openssh-client

# http proxy
apt-get install -y --no-install-recommends privoxy

# x11 window manager
apt-get install -y --no-install-recommends gosu openbox python3-xdg xvfb xterm

# vnc
apt-get install -y --no-install-recommends novnc x11vnc

# for automatic login
apt-get install -y --no-install-recommends xdotool

# for debugging purposes
apt-get install -y --no-install-recommends curl

# cisco secure client

# https://www.cisco.com/c/en/us/support/docs/security/secure-client-5/223124-configure-secure-client-vpn-for-use-in.html
apt-get install -y net-tools iptables
# additional packages required
apt-get install -y --no-install-recommends libglib2.0-0t64 libgtk-3-0t64 libwebkit2gtk-4.1-0 libxml2

# extracted files will be removed in the cleanup phase
tar xf $BASEDIR/package.tar.gz -C /tmp --strip-components=1

sed -i 's|echo "Error: systemd required.*$|echo "QUICK-HACK: systemd" >> /tmp/${LOGFNAME}|' /tmp/vpn/vpn_install.sh
(cd /tmp/vpn; yes | ./vpn_install.sh)

mkdir -p /etc/dbus-1/system.d/
mkdir -p /usr/share/dbus-1/system-services/
(cd /tmp/dart; yes | ./dart_install.sh)

# cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/tmp/*
rm -rf /tmp/*
