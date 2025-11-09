PROGNAME=$(basename $0)
echo "INFO: $PROGNAME: Start noVNC"
exec websockify --web=/usr/share/novnc 5980 localhost:5900
