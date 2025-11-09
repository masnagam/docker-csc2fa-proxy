PROGNAME=$(basename $0)

if [ -z "$SOCKS5_REMOTE_HOST" ]
then
  echo "ERROR: $PROGNAME: SOCKS5_REMOTE_HOST is required"
  exit 1
fi

if [ -z "$SOCKS5_REMOTE_USER" ]
then
  echo "ERROR: $PROGNAME: SOCKS5_REMOTE_USER is required"
  exit 1
fi

echo "INFO: $PROGNAME: Waiting for VPN connection..."
while [ -z "$(getent hosts $SOCKS5_REMOTE_HOST)" ]
do
  sleep 1s
done

echo "INFO: $PROGNAME: Establish a dynamic port forwarding connection to $SOCKS5_REMOTE_HOST"
# TODO: use known_hosts for safety
exec ssh -o StrictHostKeyChecking=no -N -D 0.0.0.0:8118 $SOCKS5_REMOTE_USER@$SOCKS5_REMOTE_HOST
