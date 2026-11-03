#!/bin/sh
# Installer for the Quickshell shell (niri + Hyprland, same shortcuts, same styles).
# Run  sh install.sh --help  for the options.
#
# Two ways to install:
#   light  adds a few lines to YOUR niri / Hyprland config and skips the keys you
#          already use. Nothing of yours is replaced. (default with --yes)
#   full   installs our niri / Hyprland configs, the setup of the screenshots.
#          Yours are backed up first and it asks before replacing.
#
# Everything it touches is saved first in ~/.config/quickshell-backup-DATE
set -e
here=$(cd "$(dirname "$0")" && pwd)
lib="$here/installer"

. "$lib/common.sh"
. "$lib/deps.sh"
. "$lib/others.sh"
. "$lib/light.sh"
. "$lib/full.sh"
. "$lib/uninstall.sh"

parse_args "$@"

if [ "$action" = uninstall ]; then
    uninstall_run
    exit 0
fi

# ── 1. what to configure ──
step "1/6" "Looking for niri / Hyprland"
detect_compositors
[ -n "$want_niri" ] && say "niri: will be configured"
[ -n "$want_hypr" ] && say "Hyprland: will be configured"

if [ -z "$mode" ]; then
    mode=light
    if [ -z "$yes" ] && [ -r /dev/tty ]; then
        printf '\n    How do you want to install it?\n'
        printf '      1) light: adds a few lines to your configs, skips the keys you already use (nothing replaced)\n'
        printf '      2) full:  our niri / Hyprland configs, like the screenshots (yours are backed up)\n'
        printf '    Choice [1]: '
        read -r c </dev/tty || c=1
        case "$c" in 2|full|f|F) mode=full ;; esac
    fi
fi
say "mode: $mode"

# ── 2. programs ──
if [ -z "$nodeps" ]; then
    step "2/6" "Checking the programs the shell needs"
    deps_check
else
    step "2/6" "Programs check skipped (--no-deps)"
fi

# ── 3. other shells ──
if [ -z "$noothers" ]; then
    step "3/6" "Looking for other shells that would conflict"
    others_run
else
    step "3/6" "Other shells: skipped (--no-others)"
fi

# ── 4. shell + compositor ──
step "4/6" "Installing the shell and the compositor setup"
say "backup folder: $bk"
say "shell -> $cfg/quickshell"
backup "$cfg/quickshell"
mkdir -p "$cfg/quickshell"
cp -a "$here/quickshell/." "$cfg/quickshell/"
chmod +x "$cfg/quickshell/scripts/"*.sh

if [ "$mode" = light ]; then
    [ -n "$want_niri" ] && light_niri
    [ -n "$want_hypr" ] && light_hypr
    light_report
else
    [ -n "$want_niri" ] && full_niri
    [ -n "$want_hypr" ] && full_hypr
fi
state_write

# ── 5. wallpapers and Firefox ──
step "5/6" "Wallpapers"
wp=$(sh "$cfg/quickshell/scripts/wallpaper-dir.sh")
mkdir -p "$wp"
say "folder: $wp"
if [ -d "$here/wallpapers" ] && ls "$here/wallpapers" | grep -qiE '\.(jpe?g|png|webp)$'; then
    cp -n "$here/wallpapers/"* "$wp/" 2>/dev/null || true
    say "copied the wallpapers that come with the shell"
fi
n=$(ls "$wp" 2>/dev/null | grep -ciE '\.(jpe?g|png|webp)$' || true)
say "$n image(s) there. Put more in that folder: Alt+W opens the picker."
if [ -z "$nodeps" ]; then
    printf '\n'
    pywalfox_setup
fi

# ── 6. start ──
step "6/6" "Starting"
if [ -z "$nostart" ] && [ -n "$WAYLAND_DISPLAY" ] && { [ -n "$NIRI_SOCKET" ] || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; } && command -v qs >/dev/null 2>&1; then
    if confirm "Start the shell now?"; then
        pkill -x quickshell 2>/dev/null || true
        sleep 0.5
        setsid qs >/dev/null 2>&1 &
        say "shell started"
    fi
else
    say "not inside a niri / Hyprland session (or --no-start): the shell starts at your next login"
fi

printf '\n\033[1mDone.\033[0m Now reload:\n'
[ -n "$want_niri" ] && say "niri:     niri msg action load-config-file"
[ -n "$want_hypr" ] && say "Hyprland: hyprctl reload"
say "shell:    qs kill; qs   (if it is not already running)"
say "undo:     sh install.sh --uninstall"
