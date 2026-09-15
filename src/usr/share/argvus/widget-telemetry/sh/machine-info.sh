#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ARGVUS_I18N_HELPER="$ARGVUS_SYSTEM_CONFIG/lib/i18n.sh"
. "$ARGVUS_I18N_HELPER"

OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
LOCALE=$(locale | awk -F= '/^LANG=/{print $2}')
UPTIME=$(uptime -p | sed 's/^up //')
KERNEL=$(uname -r)

# Desktop Environment
# e.g. "ARGVUS 0.4.0"
if command -v argvus >/dev/null 2>&1; then
  DE=$(argvus --version 2>/dev/null)
else
  DE=$(argvus_tr widget-telemetry machine.unknown)
fi

# Window Manager: compositor name + version + session type
# e.g. "Hyprland 0.56.2 (Wayland)"
WM_NAME=${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-$(argvus_tr widget-telemetry machine.unknown)}}
WM_VERSION=""
case "$WM_NAME" in
    Hyprland)
        WM_VERSION=$(hyprctl version 2>/dev/null | awk 'NR==1 {print $2}')
        ;;
    Sway)
        WM_VERSION=$(swaymsg -t get_version 2>/dev/null | awk -F'"' '/"version"/ {print $4}')
        ;;
esac

case "${XDG_SESSION_TYPE:-}" in
    wayland) SESSION_TYPE="Wayland" ;;
    x11) SESSION_TYPE="X11" ;;
    *)
        if [ -n "${WAYLAND_DISPLAY:-}" ]; then
            SESSION_TYPE="Wayland"
        elif [ -n "${DISPLAY:-}" ]; then
            SESSION_TYPE="X11"
        else
            SESSION_TYPE="$(argvus_tr widget-telemetry machine.unknown)"
        fi
        ;;
esac

if [ -n "$WM_VERSION" ]; then
    WINDOW_MANAGER="$WM_NAME $WM_VERSION ($SESSION_TYPE)"
else
    WINDOW_MANAGER="$WM_NAME ($SESSION_TYPE)"
fi

# Display: resolution, physical size, refresh rate, type
# e.g. "1920x1080 in 24\", 75 Hz [External]"
DISPLAY_INFO="$(argvus_tr widget-telemetry machine.unknown)"

# Helper: detect external vs laptop based on diagonal inches
_detect_display_type() {
    _inches=$1
    if [ -n "$_inches" ]; then
        _large=$(awk "BEGIN {print ($_inches >= 21) ? 1 : 0}")
        if [ "$_large" -eq 1 ]; then
            argvus_tr widget-telemetry display.external
        else
            argvus_tr widget-telemetry display.laptop
        fi
    else
        argvus_tr widget-telemetry machine.unknown
    fi
}

# Helper: compute diagonal inches from mm dimensions
_calc_inches() {
    _wmm=$1
    _hmm=$2
    if [ -n "$_wmm" ] && [ -n "$_hmm" ] && [ "$_wmm" -gt 0 ] 2>/dev/null && [ "$_hmm" -gt 0 ] 2>/dev/null; then
        awk "BEGIN {printf \"%.0f\", sqrt($_wmm*$_wmm + $_hmm*$_hmm) / 25.4}"
    fi
}

if command -v hyprctl >/dev/null 2>&1 && [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    _mon=$(hyprctl monitors 2>/dev/null)
    if [ -n "$_mon" ]; then
        _res_hz=$(echo "$_mon" | awk '/^\t[0-9]+x[0-9]+@/ {print $1; exit}')
        _phys=$(echo "$_mon" | awk '/physical size/ {print $NF; exit}')
        _res=$(echo "$_res_hz" | sed 's/@.*//')
        _hz=$(echo "$_res_hz" | sed 's/.*@//' | awk '{printf "%.0f", $1}')
        _wmm=$(echo "$_phys" | cut -dx -f1)
        _hmm=$(echo "$_phys" | cut -dx -f2)
        _inches=$(_calc_inches "$_wmm" "$_hmm")
        _dtype=$(_detect_display_type "$_inches")
        if [ -n "$_inches" ]; then
            DISPLAY_INFO=$(argvus_tr widget-telemetry display.resolution \
                "resolution=$_res" "inches=$_inches" "refresh=$_hz" "type=$_dtype")
        else
            DISPLAY_INFO=$(argvus_tr widget-telemetry display.resolution_simple \
                "resolution=$_res" "refresh=$_hz")
        fi
    fi
elif command -v xrandr >/dev/null 2>&1; then
    _line=$(xrandr --query 2>/dev/null | awk '/ connected/ {print $0; exit}')
    if [ -n "$_line" ]; then
        _res_hz=$(echo "$_line" | awk '{for(i=3;i<=NF;i++) if($i ~ /^[0-9]+x[0-9]+\+/) {print $i; exit}}' | sed 's/+.*//')
        _phys=$(echo "$_line" | grep -o '[0-9]*mm x [0-9]*mm' | head -1)
        _res=$(echo "$_res_hz" | cut -d+ -f1)
        _hz=$(xrandr --query 2>/dev/null | awk '/^\s+[0-9]+x[0-9]+\s+\*/{print $2; exit}')
        _hz=${_hz%.*}
        _wmm=$(echo "$_phys" | awk -F'mm x ' '{print $1}')
        _hmm=$(echo "$_phys" | awk -F'mm x ' '{gsub(/mm/,"",$2); print $2}')
        _inches=$(_calc_inches "$_wmm" "$_hmm")
        _dtype=$(_detect_display_type "$_inches")
        if [ -n "$_inches" ]; then
            DISPLAY_INFO=$(argvus_tr widget-telemetry display.resolution \
                "resolution=$_res" "inches=$_inches" "refresh=$_hz" "type=$_dtype")
        else
            DISPLAY_INFO=$(argvus_tr widget-telemetry display.resolution_simple \
                "resolution=$_res" "refresh=$_hz")
        fi
    fi
fi

CPU=$(LC_ALL=C lscpu | awk -F: '
/Model name/ {
    gsub(/^[ \t]+/, "", $2)
    print $2
    exit
}' | sed 's/(R)//g; s/(TM)//g; s/Core//g; s/  */ /g')

GPU=$(lspci | awk -F': ' '
/VGA compatible controller|3D controller/ {
    print $2
    exit
}' | sed 's/.*\[\(.*\)\].*/\1/')

TEXT=$(
cat <<EOF
<span>$(argvus_tr widget-telemetry machine.os):</span>       $OS
<span>$(argvus_tr widget-telemetry machine.desktop):</span>       $DE
<span>$(argvus_tr widget-telemetry machine.kernel):</span>   $KERNEL
<span>$(argvus_tr widget-telemetry machine.locale):</span>   $LOCALE
<span>$(argvus_tr widget-telemetry machine.uptime):</span>   $UPTIME
<span>$(argvus_tr widget-telemetry machine.window_manager):</span>       $WINDOW_MANAGER
<span>$(argvus_tr widget-telemetry machine.display):</span>  $(json_escape "$DISPLAY_INFO")
<span>$(argvus_tr widget-telemetry machine.cpu):</span>      $CPU
<span>$(argvus_tr widget-telemetry machine.gpu):</span>      $GPU
EOF
)

json_output "$TEXT"
