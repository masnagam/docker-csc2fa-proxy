PROGNAME=$(basename $0)

echo "INFO: $PROGNAME: Start privoxy"

mkdir -p $HOME/privoxy
cat >$HOME/privoxy/config <<EOF
confdir $HOME/privoxy
listen-address 0.0.0.0:8118
debug 1
debug 1024
debug 4096
debug 8192
EOF

ln -sf /etc/privoxy/templates $HOME/privoxy/

exec /usr/sbin/privoxy --no-daemon $HOME/privoxy/config
