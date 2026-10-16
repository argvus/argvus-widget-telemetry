#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

# Render nothing while the widget is scrolled past this block or it does not fit.
TOGGLE="${ARGVUS_WIDGET_TELEMETRY_TOGGLE:-/usr/lib/argvus/commands/argvus-widget-telemetry-toggle}"
case " $("$TOGGLE" visible) " in
  *" keys "*) ;;
  *) exit 0 ;;
esac

argvus_tr widget-telemetry keys.format
