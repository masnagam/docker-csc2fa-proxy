PROXY_SH=/app/privoxy.sh
if [ -n "$SOCKS5_REMOTE_HOST" ]
then
  PROXY_SH=/app/socks5.sh
elif [ -n "$SOCAT_REMOTE_HOST" ]
then
  PROXY_SH=/app/socat.sh
fi

mkdir -p $HOME/.config/openbox
cat <<EOF >$HOME/.config/openbox/autostart
python3 /app/vpn.py &
(sleep 1s && sh /app/x11vnc.sh) &
(sleep 2s && sh /app/novnc.sh) &
(sleep 3s && sh $PROXY_SH) &
EOF

# AT-SPI (used by vpn.py) requires a D-Bus session bus.
exec dbus-run-session -- xvfb-run -s "-screen 0 1270x720x24" openbox-session
