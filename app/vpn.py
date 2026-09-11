#!/usr/bin/env python3
"""Cisco Secure Client login automation driven by AT-SPI (accessibility) state.

Each step waits until the target UI element actually exists and is visible
before acting, instead of relying on fixed sleeps.  Keystrokes are sent with
xdotool after focusing the exact target element so that JavaScript handlers
in the WebKit login form work as usual.
"""

import os
import subprocess
import sys
import time

import pyatspi

VPNUI = "/opt/cisco/secureclient/bin/vpnui"
MAIN_WINDOW = "Cisco Secure Client"
LOGIN_DIALOG = "Cisco Secure Client - Login"
POLL_INTERVAL = 0.2


def log(msg):
    print("INFO: vpn.py: %s" % msg, flush=True)


def extra_sleep(name):
    value = os.environ.get(name, "0s")
    try:
        return float(value.rstrip("s"))
    except ValueError:
        log("WARN: invalid %s value %r; using 0s" % (name, value))
        return 0.0


# Extra buffers for environments that need more settling time.
SLEEP_FOR_SERVER_NAME = extra_sleep("SLEEP_FOR_SERVER_NAME")
SLEEP_FOR_USERNAME = extra_sleep("SLEEP_FOR_USERNAME")
SLEEP_FOR_PASSWORD = extra_sleep("SLEEP_FOR_PASSWORD")


def read_secret(name):
    with open("/run/secrets/" + name) as f:
        return f.read().strip()


SERVER_NAME = read_secret("server-name")
USERNAME = read_secret("username")
PASSWORD = read_secret("password")


def each_app():
    desktop = pyatspi.Registry.getDesktop(0)
    for i in range(desktop.childCount):
        yield desktop.getChildAtIndex(i)


def each_node(root, depth=0):
    if depth > 20:  # guard against runaway recursion, not a correctness limit
        return
    yield root
    for i in range(root.childCount):
        yield from each_node(root.getChildAtIndex(i), depth + 1)


def is_usable(node):
    states = node.getState().getStates()
    return pyatspi.STATE_SHOWING in states and pyatspi.STATE_ENABLED in states


def find_window(name):
    for app in each_app():
        try:
            for node in each_node(app):
                if node.getRoleName() in ("frame", "dialog") and node.name == name:
                    return node
        except Exception:
            continue
    return None


def find_node(root, pred):
    for node in each_node(root):
        try:
            if pred(node) and is_usable(node):
                return node
        except Exception:
            continue
    return None


def wait_for(desc, fn, timeout):
    log("Waiting for %s..." % desc)
    deadline = time.monotonic() + timeout
    while True:
        try:
            result = fn()
            if result:
                log("Found %s" % desc)
                return result
        except Exception:
            pass
        if time.monotonic() > deadline:
            sys.exit("ERROR: vpn.py: timed out waiting for %s" % desc)
        time.sleep(POLL_INTERVAL)


def xdotool(*args):
    subprocess.run(["xdotool", *args], check=True)


def focus(node):
    """Focus *node*, returning True only once the focused state is observed."""
    try:
        if not node.queryComponent().grabFocus():
            return False
        deadline = time.monotonic() + 2
        while time.monotonic() < deadline:
            if pyatspi.STATE_FOCUSED in node.getState().getStates():
                return True
            time.sleep(POLL_INTERVAL)
    except Exception:
        pass
    return False


def type_into(node, text):
    if not focus(node):
        # Fall back to activating the window and typing into its focused field.
        log("WARN: could not focus the target element; activating the window instead")
        try:
            subprocess.run(["xdotool", "search", "--sync", "--onlyvisible",
                            "--name", LOGIN_DIALOG, "windowactivate", "--sync"],
                           timeout=10, check=True)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            log("WARN: could not activate the login dialog; typing anyway")
    # Pass the text via stdin so secrets stay out of the process list.
    subprocess.run(["xdotool", "type", "--clearmodifiers", "--file", "/dev/stdin"],
                   input=text.encode(), check=True)


def press_return():
    xdotool("key", "--clearmodifiers", "Return")


# DART requires the Desktop folder.
os.makedirs(os.path.expanduser("~/Desktop"), exist_ok=True)

log("Launching %s..." % MAIN_WINDOW)
vpnui = subprocess.Popen([VPNUI])

main = wait_for("the main window", lambda: find_window(MAIN_WINDOW), timeout=60)
# The status bar is the application's own readiness signal.
wait_for("the ready-to-connect status",
         lambda: find_node(main, lambda n: n.getRoleName() == "status bar"
                           and (n.name or "").startswith("Ready to connect.")),
         timeout=60)
time.sleep(SLEEP_FOR_SERVER_NAME)

entry = wait_for("the server address entry",
                 lambda: find_node(main, lambda n: n.getRoleName() == "text"),
                 timeout=30)
log("Entering the server name...")
entry.queryEditableText().setTextContents("https://" + SERVER_NAME)

button = find_node(main, lambda n: n.getRoleName() == "push button" and n.name == "Connect")
if button:
    button.queryAction().doAction(0)
else:
    entry.queryComponent().grabFocus()
    press_return()

dialog = wait_for("the login dialog", lambda: find_window(LOGIN_DIALOG), timeout=90)

time.sleep(SLEEP_FOR_USERNAME)
username_field = wait_for("the username field",
                          lambda: find_node(dialog, lambda n: n.getRoleName() in ("text", "entry")),
                          timeout=60)
log("Entering the username...")
type_into(username_field, USERNAME)
press_return()

time.sleep(SLEEP_FOR_PASSWORD)
password_field = wait_for("the password field",
                          lambda: find_node(dialog, lambda n: n.getRoleName() == "password text"),
                          timeout=60)
log("Entering the password...")
type_into(password_field, PASSWORD)
press_return()

log("Done. Complete the authentication on your device.")
vpnui.wait()
