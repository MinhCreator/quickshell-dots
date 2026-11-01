#!/bin/sh
# Installer for the Quickshell shell (niri + Hyprland, same shortcuts, same styles).
#
#   sh install.sh              detects niri / Hyprland and installs for what you have
#   sh install.sh --niri       only niri
#   sh install.sh --hyprland   only Hyprland
#   sh install.sh --all        both
#   sh install.sh --yes        do not ask anything (installs missing programs too)
#   sh install.sh --no-deps    skip the check for missing programs
#   sh install.sh --purge      also uninstall the packages of other shells (noctalia, caelestia, DMS)
#
# Everything it replaces is saved first in ~/.config/quickshell-backup-DATE
set -e
here=$(cd "$(dirname "$0")" && pwd)
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
bk="$cfg/quickshell-backup-$(date +%Y%m%d-%H%M%S)"

want_niri=""; want_hypr=""; yes=""; nodeps=""; purge=""; purge=""
for a in "$@"; do
    case "$a" in
        --niri) want_niri=1 ;;
        --hyprland|--hypr) want_hypr=1 ;;
        --all) want_niri=1; want_hypr=1 ;;
        --yes|-y) yes=1 ;;
        --no-deps) nodeps=1 ;;
        --purge) purge=1 ;;
        -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
        *) echo "unknown option: $a"; exit 1 ;;
    esac
done
if [ -z "$want_niri$want_hypr" ]; then
    [ -d "$cfg/niri" ] && want_niri=1
    [ -d "$cfg/hypr" ] && want_hypr=1
    if [ -z "$want_niri$want_hypr" ]; then
        command -v niri >/dev/null 2>&1 && want_niri=1
        command -v Hyprland >/dev/null 2>&1 && want_hypr=1
    fi
    [ -z "$want_niri$want_hypr" ] && { echo "niri / Hyprland not found: use --niri, --hyprland or --all"; exit 1; }
fi

step() { printf '\n\033[1m[%s]\033[0m %s\n' "$1" "$2"; }
say()  { printf '    %s\n' "$*"; }

step "1/6" "Looking for niri / Hyprland"
[ -n "$want_niri" ] && say "niri: will be configured"
[ -n "$want_hypr" ] && say "Hyprland: will be configured"

# ── dependencies ──
# command:package (Arch). awww can be swww, magick can be convert.
have() {
    case "$1" in
        awww) command -v awww >/dev/null 2>&1 || command -v swww >/dev/null 2>&1 ;;
        magick) command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 ;;
        *) command -v "$1" >/dev/null 2>&1 ;;
    esac
}
deps="qs:quickshell awww:awww wal:python-pywal jq:jq grim:grim slurp:slurp wf-recorder:wf-recorder
ffmpeg:ffmpeg wpctl:wireplumber playerctl:playerctl brightnessctl:brightnessctl cava:cava
cliphist:cliphist wl-mirror:wl-mirror magick:imagemagick notify-send:libnotify
inotifywait:inotify-tools pywalfox:pywalfox xdg-user-dir:xdg-user-dirs"

if [ -z "$nodeps" ]; then
    step "2/6" "Checking the programs the shell needs"
    miss_cmd=""; miss_pkg=""
    for d in $deps; do
        c=${d%%:*}; p=${d#*:}
        if have "$c"; then say "ok       $c"; else say "MISSING  $c  (package: $p)"; miss_cmd="$miss_cmd $c"; miss_pkg="$miss_pkg $p"; fi
    done
    if [ -z "$miss_pkg" ]; then
        say "everything is installed"
    elif ! command -v pacman >/dev/null 2>&1; then
        say "this is not Arch: install these with your package manager:$miss_pkg"
    else
        r=y
        if [ -z "$yes" ]; then
            printf '    Install the missing packages now? [Y/n] '
            read -r r </dev/tty || r=y
        fi
        case "$r" in
            n|N) say "skipped: install later:$miss_pkg" ;;
            *)
                repo=""; aur=""
                for p in $miss_pkg; do
                    if pacman -Si "$p" >/dev/null 2>&1; then repo="$repo $p"; else aur="$aur $p"; fi
                done
                if [ -n "$repo" ]; then
                    say "installing from the official repositories:$repo"
                    sudo pacman -S --needed --noconfirm $repo || say "pacman failed: continuing"
                fi
                if [ -n "$aur" ]; then
                    helper=""
                    command -v paru >/dev/null 2>&1 && helper=paru
                    [ -z "$helper" ] && command -v yay >/dev/null 2>&1 && helper=yay
                    if [ -n "$helper" ]; then
                        say "installing from the AUR with $helper:$aur"
                        $helper -S --needed --noconfirm $aur || say "$helper failed: continuing"
                    else
                        say "from the AUR (no yay/paru found, install them by hand):$aur"
                    fi
                fi
                if command -v pywalfox >/dev/null 2>&1; then
                    say "registering Pywalfox in Firefox (you still need its Firefox add-on)"
                    pywalfox install >/dev/null 2>&1 || true
                fi
                ;;
        esac
    fi
else
    step "2/6" "Programs check skipped (--no-deps)"
fi

step "3/6" "Backup of what will be replaced"
mkdir -p "$bk"
say "backup in $bk"
backup() { [ -e "$1" ] || return 0; mkdir -p "$bk/$(dirname "${1#$cfg/}")"; cp -a "$1" "$bk/${1#$cfg/}"; }
ask() {
    [ -n "$yes" ] && return 0
    [ -e "$1" ] || return 0
    printf '%s exists and will be replaced (backup saved). Continue? [Y/n] ' "$1"
    read -r r </dev/tty || return 0
    case "$r" in n|N) return 1 ;; esac
}
put() { # put SRC DST
    if ask "$2"; then backup "$2"; cp "$1" "$2"; else echo "skipped $2"; fi
}

# ── other shells (noctalia, caelestia, DMS...) ──
step "4/6" "Looking for other shells that would conflict"
# name|folders (relative to $HOME)|process|packages|systemd user unit
shells="noctalia|.config/noctalia .cache/noctalia|noctalia-shell|noctalia-shell|noctalia
caelestia|.config/caelestia .local/state/caelestia .local/share/caelestia|caelestia|caelestia-shell caelestia-cli|
dms|.config/DankMaterialShell .local/state/DankMaterialShell .cache/DankMaterialShell|dms|dms-shell-bin dms-shell-git dms-shell dankmaterialshell|dms
illogical-impulse|.config/illogical-impulse||illogical-impulse-quickshell-git|"
# only stopped, never uninstalled: bars and notification daemons (our shell has its own)
others="waybar hyprpanel ags eww mako dunst swaync swayosd-server"

found=""
OLDIFS=$IFS; IFS='
'
for line in $shells; do
    IFS=$OLDIFS
    name=${line%%|*}; rest=${line#*|}; dirs=${rest%%|*}; rest=${rest#*|}; proc=${rest%%|*}; rest=${rest#*|}; pk=${rest%%|*}; unit=${rest#*|}
    hit=""
    for d in $dirs; do [ -e "$HOME/$d" ] && hit=1; done
    [ -n "$proc" ] && pgrep -x "$proc" >/dev/null 2>&1 && hit=1
    for p in $pk; do command -v pacman >/dev/null 2>&1 && pacman -Q "$p" >/dev/null 2>&1 && hit=1; done
    [ -n "$hit" ] && { found="$found $name"; say "found: $name"; }
    IFS='
'
done
IFS=$OLDIFS
# Quickshell configs of other shells living next to ours (~/.config/quickshell/<name>/shell.qml)
sub=""
for f in "$cfg"/quickshell/*/shell.qml; do
    [ -e "$f" ] || continue
    d=$(dirname "$f"); n=$(basename "$d")
    [ -e "$here/quickshell/$n/shell.qml" ] && continue
    sub="$sub $d"; say "found: another Quickshell config in quickshell/$n"
done
running=""
for p in $others; do pgrep -x "$p" >/dev/null 2>&1 && running="$running $p"; done
[ -n "$running" ] && say "running and will be stopped:$running"

if [ -z "$found$sub$running" ]; then
    say "none: nothing to remove"
else
    r=y
    if [ -z "$yes" ]; then
        printf '    Remove them? (settings go to the backup, nothing is lost) [Y/n] '
        read -r r </dev/tty || r=y
    fi
    case "$r" in
        n|N) say "skipped: they may fight with this shell (two bars, two notification daemons)" ;;
        *)
            mkdir -p "$bk/removed"
            OLDIFS=$IFS; IFS='
'
            for line in $shells; do
                IFS=$OLDIFS
                name=${line%%|*}; rest=${line#*|}; dirs=${rest%%|*}; rest=${rest#*|}; proc=${rest%%|*}; rest=${rest#*|}; pk=${rest%%|*}; unit=${rest#*|}
                case " $found " in *" $name "*) ;; *) IFS='
'; continue ;; esac
                say "$name: stopping"
                [ -n "$proc" ] && pkill -x "$proc" 2>/dev/null || true
                [ -n "$unit" ] && systemctl --user disable --now "$unit" >/dev/null 2>&1 || true
                for d in $dirs; do
                    if [ -e "$HOME/$d" ]; then
                        mkdir -p "$bk/removed/$(dirname "$d")"
                        mv "$HOME/$d" "$bk/removed/$d"
                        say "$name: moved ~/$d to the backup"
                    fi
                done
                if [ -n "$purge" ] && command -v pacman >/dev/null 2>&1; then
                    inst=""
                    for p in $pk; do pacman -Q "$p" >/dev/null 2>&1 && inst="$inst $p"; done
                    [ -n "$inst" ] && { say "$name: uninstalling$inst"; sudo pacman -Rns --noconfirm $inst || say "could not uninstall"; }
                fi
                IFS='
'
            done
            IFS=$OLDIFS
            pkill -f 'qs -c (noctalia-shell|noctalia|caelestia|dms|ii)' 2>/dev/null || true
            for d in $sub; do
                n=$(basename "$d"); mkdir -p "$bk/removed/quickshell"
                mv "$d" "$bk/removed/quickshell/$n"; say "moved quickshell/$n to the backup"
            done
            for p in $running; do say "stopping $p"; pkill -x "$p" 2>/dev/null || true; done
            # leftovers of these shells in the compositor folders
            for f in niri/noctalia.kdl niri/dms hypr/noctalia.lua hypr/noctalia hypr/dms; do
                if [ -e "$cfg/$f" ]; then mkdir -p "$bk/removed/$(dirname "$f")"; mv "$cfg/$f" "$bk/removed/$f"; say "moved $f to the backup"; fi
            done
            [ -z "$purge" ] && [ -n "$found" ] && say "their packages stay installed (use --purge to uninstall them too)"
            ;;
    esac
fi

# ── shell ──
step "5/6" "Installing the shell and the compositor config"
say "shell -> $cfg/quickshell"
backup "$cfg/quickshell"
mkdir -p "$cfg/quickshell"
cp -a "$here/quickshell/." "$cfg/quickshell/"
chmod +x "$cfg/quickshell/scripts/"*.sh

# ── niri ──
if [ -n "$want_niri" ]; then
    say "niri -> $cfg/niri (config.kdl, quickshell.kdl)"
    mkdir -p "$cfg/niri"
    put "$here/niri/config.kdl" "$cfg/niri/config.kdl"
    put "$here/niri/quickshell.kdl" "$cfg/niri/quickshell.kdl"
    # managed by the shell: created only if missing
    for f in quickshell-tweaks.kdl quickshell-outputs.kdl; do
        [ -e "$cfg/niri/$f" ] || cp "$here/niri/$f" "$cfg/niri/$f"
    done
    # leftovers of older setups
    for f in config.kdl.old backdrop.fish noctalia.kdl; do
        [ -e "$cfg/niri/$f" ] && { backup "$cfg/niri/$f"; rm -f "$cfg/niri/$f"; }
    done
fi

# ── Hyprland ──
if [ -n "$want_hypr" ]; then
    say "Hyprland -> $cfg/hypr (hyprland.lua, quickshell-binds.lua)"
    mkdir -p "$cfg/hypr"
    put "$here/hypr/hyprland.lua" "$cfg/hypr/hyprland.lua"
    cp "$here/hypr/quickshell-binds.lua" "$cfg/hypr/quickshell-binds.lua"
    [ -e "$cfg/hypr/quickshell-outputs.lua" ] || cp "$here/hypr/quickshell-outputs.lua" "$cfg/hypr/quickshell-outputs.lua"
    for f in monitors.conf workspaces.conf monitors.lua scripts/record.sh scripts/qs-record.sh pywalfox-autoupdate.sh; do
        [ -e "$cfg/hypr/$f" ] && { backup "$cfg/hypr/$f"; rm -f "$cfg/hypr/$f"; }
    done
fi

# ── wallpapers ──
step "6/6" "Wallpapers"
wp=$(sh "$cfg/quickshell/scripts/wallpaper-dir.sh")
mkdir -p "$wp"
say "folder: $wp"
if [ -d "$here/wallpapers" ] && ls "$here/wallpapers" | grep -qiE '\.(jpe?g|png|webp)$'; then
    cp -n "$here/wallpapers/"* "$wp/" 2>/dev/null || true
    say "copied the wallpapers that come with the shell"
fi
n=$(ls "$wp" 2>/dev/null | grep -ciE '\.(jpe?g|png|webp)$' || true)
say "$n image(s) there. Put more in that folder: Alt+W opens the picker."

printf '\n\033[1mDone.\033[0m Now reload:\n'
[ -n "$want_niri" ] && say "niri:     niri msg action load-config-file"
[ -n "$want_hypr" ] && say "Hyprland: hyprctl reload"
say "shell:    qs kill; qs"
