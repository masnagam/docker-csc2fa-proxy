PROGNAME=$(basename $0)

if [ -z "$SOCAT_REMOTE_HOST" ]
then
  echo "ERROR: $PROGNAME: SOCAT_REMOTE_HOST is required"
  exit 1
fi

if [ -z "$SOCAT_REMOTE_PORT" ]
then
  echo "ERROR: $PROGNAME: SOCAT_REMOTE_PORT is required"
  exit 1
fi

echo "INFO: $PROGNAME: Waiting for VPN connection..."
while [ -z "$(getent hosts $SOCAT_REMOTE_HOST)" ]
do
  sleep 1s
done

echo "INFO: $PROGNAME: Started forwarding..."
exec socat $SOCAT_EXTRA_OPTIONS TCP-LISTEN:8118,fork,reuseaddr,bind=0.0.0.0 TCP:$SOCAT_REMOTE_HOST:$SOCAT_REMOTE_PORT
