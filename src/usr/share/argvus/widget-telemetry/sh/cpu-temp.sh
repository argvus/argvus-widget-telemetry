#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

cpu_temp() {
  for h in /sys/class/hwmon/hwmon*; do
    [ -r "$h/name" ] || continue

    case "$(cat "$h/name")" in
    coretemp | k10temp | zenpower)
      for label in "$h"/temp*_label; do
        [ -r "$label" ] || continue

        case "$(cat "$label")" in
        "Package id 0" | Tctl | Tdie | Package)
          input="${label%_label}_input"
          awk '{printf "%.0f", $1/1000}' "$input"
          return 0
          ;;
        esac
      done

      awk '{printf "%.0f", $1/1000}' "$h/temp1_input" 2>/dev/null && return 0
      ;;
    esac
  done

  for t in /sys/class/hwmon/hwmon*/temp*_input; do
    [ -r "$t" ] || continue
    awk '{printf "%.0f", $1/1000}' "$t"
    return 0
  done

  return 1
}

case "${1:-}" in
  --available)
    cpu_temp >/dev/null
    exit $?
    ;;
esac

cpu_temp || exit 1
