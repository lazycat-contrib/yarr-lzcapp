#!/bin/sh
# Yarr has no web login of its own by default: without --auth-file every
# request is served to anyone who reaches the port. This wrapper always renders
# a username:password auth file from the deployment parameters, so the reader
# is never exposed unauthenticated.
#
# The file lives on tmpfs at /run/yarr and is mode 600, so the credential is not
# stored in the package or next to the feed database.
set -eu

USER_NAME="${YARR_USER:-}"
USER_PASS="${YARR_PASS:-}"

fail() {
    echo "[yarr] refusing to start: $1" >&2
    # Never echo the offending value itself.
    exit 1
}

[ -n "$USER_NAME" ] || fail "YARR_USER must be set"
[ -n "$USER_PASS" ] || fail "YARR_PASS must be set"

# Yarr splits the auth line on the first colon, so a colon in either half would
# silently move the boundary.
case "$USER_NAME$USER_PASS" in
    *:*) fail "username and secret must not contain a colon" ;;
esac
case "$USER_NAME" in
    *[!A-Za-z0-9_.@-]*) fail "YARR_USER may only contain letters, digits and _ . @ -" ;;
esac
[ "${#USER_PASS}" -ge 12 ] || fail "YARR_PASS must be at least 12 characters"

AUTH_DIR=/run/yarr
AUTH_FILE="$AUTH_DIR/auth"
mkdir -p "$AUTH_DIR"
chmod 700 "$AUTH_DIR"
printf '%s:%s\n' "$USER_NAME" "$USER_PASS" > "$AUTH_FILE"
chmod 600 "$AUTH_FILE"

exec /usr/local/bin/yarr \
    -addr 0.0.0.0:7070 \
    -db /data/yarr.db \
    -auth-file "$AUTH_FILE"
