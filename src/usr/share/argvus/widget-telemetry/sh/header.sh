#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

key="$1"

case "$key" in
  system)    argvus_tr widget-telemetry header.system ;;
  cpu_gpu)   argvus_tr widget-telemetry header.cpu_gpu ;;
  memory)    argvus_tr widget-telemetry header.memory ;;
  storage)   argvus_tr widget-telemetry header.storage ;;
  processes) argvus_tr widget-telemetry header.processes ;;
  network)   argvus_tr widget-telemetry header.network ;;
  keys)      argvus_tr widget-telemetry header.keys ;;
  dev_dashboard) argvus_tr widget-telemetry header.dev_dashboard ;;
esac
