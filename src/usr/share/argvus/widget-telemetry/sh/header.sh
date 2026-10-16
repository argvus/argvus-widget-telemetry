#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

key="$1"
TOGGLE="${ARGVUS_WIDGET_TELEMETRY_TOGGLE:-/usr/lib/argvus/commands/argvus-widget-telemetry-toggle}"

layout="$("$TOGGLE" layout)"
layout_value() {
  printf '%s\n' "$layout" | sed -n "s/^$1=//p"
}

# A header is hidden together with its block, so it prints nothing then.
case " $(layout_value visible) " in
  *" $key "*) ;;
  *) exit 0 ;;
esac

case "$key" in
  system)    label="$(argvus_tr widget-telemetry header.system)" ;;
  cpu_gpu)   label="$(argvus_tr widget-telemetry header.cpu_gpu)" ;;
  memory)    label="$(argvus_tr widget-telemetry header.memory)" ;;
  storage)   label="$(argvus_tr widget-telemetry header.storage)" ;;
  processes) label="$(argvus_tr widget-telemetry header.processes)" ;;
  network)   label="$(argvus_tr widget-telemetry header.network)" ;;
  keys)      label="$(argvus_tr widget-telemetry header.keys)" ;;
  dev_dashboard) label="$(argvus_tr widget-telemetry header.dev_dashboard)" ;;
  *) exit 0 ;;
esac

# Arrows mark content that is scrolled out of view above or below the window.
if [ "$key" = "$(layout_value first)" ] && [ "$(layout_value above)" = 1 ]; then
  label="$label ▲"
fi
if [ "$key" = "$(layout_value last)" ] && [ "$(layout_value below)" = 1 ]; then
  label="$label ▼"
fi

printf '%s\n' "$label"
