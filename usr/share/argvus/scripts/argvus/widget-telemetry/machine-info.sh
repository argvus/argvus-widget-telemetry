#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
LOCALE=$(locale | awk -F= '/^LANG=/{print $2}')
UPTIME=$(uptime -p | sed 's/^up //')
KERNEL=$(uname -r)
WINDOW_MANAGER=${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-Unknown}}

case "${XDG_SESSION_TYPE:-}" in
    wayland) DISPLAY_SERVER="Wayland" ;;
    x11) DISPLAY_SERVER="X11" ;;
    *)
        if [ -n "${WAYLAND_DISPLAY:-}" ]; then
            DISPLAY_SERVER="Wayland"
        elif [ -n "${DISPLAY:-}" ]; then
            DISPLAY_SERVER="X11"
        else
            DISPLAY_SERVER="Unknown"
        fi
        ;;
esac

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
<span>OS:</span>       $OS
<span>Kernel:</span>   $KERNEL
<span>Locale:</span>   $LOCALE
<span>Uptime:</span>   $UPTIME
<span>WM:</span>       $WINDOW_MANAGER
<span>Display:</span>  $DISPLAY_SERVER
<span>CPU:</span>      $CPU
<span>GPU:</span>      $GPU
EOF
)

json_output "$TEXT"
