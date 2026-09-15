#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

N_PROC="5"
PS="/usr/bin/ps"
AWK="/usr/bin/awk"

# shellcheck disable=SC2016
OUTPUT=$(
  {
    printf "%-7s %-5s %-5s %s\n" \
      "$(argvus_tr widget-telemetry label.pid)" \
      "$(argvus_tr widget-telemetry label.cpu_percent)" \
      "$(argvus_tr widget-telemetry label.memory_percent)" \
      "$(argvus_tr widget-telemetry label.command)"

    $PS -eo pid,pcpu,pmem,comm --no-headers |
      sort -k2 -rn |
      head -n "$N_PROC" |
      $AWK '
        {
            printf "%-7s %-5.1f %-5.1f %s\n",
                   $1, $2, $3, $4
        }'
  }
)

json_output "$OUTPUT"
