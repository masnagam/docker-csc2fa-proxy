PROGNAME=$(basename $0)
VPNUI_WM_CLASS="com.cisco.secureclient.gui"
VPNUI_WM_NAME="Cisco Secure Client"
VPNUI_WM_DIALOG_CLASS="Cisco Secure Client"
VPNUI_WM_DIALOG_NAME="Cisco Secure Client - Login"

# Load variables.

SLEEP_FOR_SERVER_NAME=${SLEEP_FOR_SERVER_NAME:-10s}
SLEEP_FOR_USERNAME=${SLEEP_FOR_USERNAME:-0s}
SLEEP_FOR_PASSWORD=${SLEEP_FOR_PASSWORD:-0s}

# Load secrets.
SERVER_NAME=$(cat /run/secrets/server-name)
USERNAME=$(cat /run/secrets/username)
PASSWORD=$(cat /run/secrets/password)

# DART requires the Desktop folder.
mkdir -p $HOME/Desktop

echo "INFO: $PROGNAME: Launching $VPNUI_WM_NAME..."
/opt/cisco/secureclient/bin/vpnui &
VPNUI_PID=$!

echo "INFO: $PROGNAME: Waiting $SLEEP_FOR_SERVER_NAME for ready to enter the server name..."
sleep $SLEEP_FOR_SERVER_NAME

echo "INFO: $PROGNAME: Entering the server name..."
xdotool search --sync --onlyvisible --name "$VPNUI_WM_NAME" \
        windowactivate --sync \
        type "https://$SERVER_NAME"
xdotool key Return

echo "INFO: $PROGNAME: Waiting $SLEEP_FOR_USERNAME for ready to enter the username..."
sleep $SLEEP_FOR_USERNAME

echo "INFO: $PROGNAME: Entering the username..."
xdotool search --sync --onlyvisible --name "$VPNI_DIALOG_WM_NAME"  \
        windowactivate --sync \
        type "$USERNAME"
xdotool key Return

echo "INFO: $PROGNAME: Waiting $SLEEP_FOR_PASSWORD for ready to enter the password..."
sleep $SLEEP_FOR_PASSWORD

echo "INFO: $PROGNAME: Entering the password..."
xdotool search --sync --onlyvisible --name "$VPNI_DIALOG_WM_NAME" \
        windowactivate --sync \
        type "$PASSWORD"
xdotool key Return

wait $VPNUI_PID
