#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

argvus_tr widget-telemetry keys.format
