#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

N_PORTS="5"
ACTIVE_PROJECT_FILE="${XDG_RUNTIME_DIR:-/tmp}/argvus/active-project"

project_line() {
  if [ -r "$ACTIVE_PROJECT_FILE" ]; then
    project_path=$(sed -n '1p' "$ACTIVE_PROJECT_FILE")
  else
    project_path=""
  fi

  if [ -z "$project_path" ] || [ ! -d "$project_path" ]; then
    printf '%s\n' "$(argvus_tr widget-telemetry dev_dashboard.no_project)"
    return 1
  fi

  printf "%-11s %s\n" "$(argvus_tr widget-telemetry label.project)" "$(basename "$project_path")"
  return 0
}

git_line() {
  if ! git -C "$project_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf "%-11s %s\n" "$(argvus_tr widget-telemetry label.branch)" "$(argvus_tr widget-telemetry dev_dashboard.not_git)"
    return
  fi

  branch=$(git -C "$project_path" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$(git -C "$project_path" status --porcelain 2>/dev/null)" ]; then
    status=$(argvus_tr widget-telemetry label.dirty)
  else
    status=$(argvus_tr widget-telemetry label.clean)
  fi
  printf "%-11s %s (%s)\n" "$(argvus_tr widget-telemetry label.branch)" "$branch" "$status"
}

ports_line() {
  ports=$(ss -tln 2>/dev/null | awk 'NR>1 {print $4}' | sed 's/.*://' | sort -un)
  count=0
  [ -n "$ports" ] && count=$(printf '%s\n' "$ports" | wc -l)
  shown=$(printf '%s\n' "$ports" | head -n "$N_PORTS" | tr '\n' ',' | sed 's/,$//')
  if [ "$count" -gt "$N_PORTS" ]; then
    shown="${shown},+$((count - N_PORTS))"
  fi
  printf "%-11s %s %s\n" "$(argvus_tr widget-telemetry label.ports)" "$count" "$shown"
}

containers_line() {
  total=0
  available=0
  if command -v podman >/dev/null 2>&1; then
    available=1
    total=$((total + $(podman ps -q 2>/dev/null | wc -l)))
  fi
  if command -v docker >/dev/null 2>&1; then
    available=1
    total=$((total + $(docker ps -q 2>/dev/null | wc -l)))
  fi
  if [ "$available" -eq 0 ]; then
    printf "%-11s %s\n" "$(argvus_tr widget-telemetry label.containers)" "$(argvus_tr widget-telemetry dev_dashboard.containers_unavailable)"
  else
    printf "%-11s %s\n" "$(argvus_tr widget-telemetry label.containers)" "$total"
  fi
}

TEXT=$(
  if project_line; then
    git_line
  fi
  ports_line
  containers_line
)

json_output "$TEXT"
