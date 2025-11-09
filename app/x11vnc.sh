PROGNAME=$(basename $0)
echo "INFO: $PROGNAME: Start x11vnc"
exec x11vnc -localhost -forever -xkb -nopw -noxdamage
