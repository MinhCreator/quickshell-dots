# shellcheck shell=sh
# Other shells (noctalia, caelestia, DMS, illogical-impulse...) fight with this one:
# two bars, two notification daemons. Look for them, and on request stop them and
# move their settings into the backup (nothing is deleted).

# name;folders (relative to $HOME);regex of the running process;packages;systemd user unit
shells="noctalia;.config/noctalia .cache/noctalia;^([^ ]*/)?(noctalia-shell|(quickshell|qs) .*noctalia);noctalia-shell;noctalia
caelestia;.config/caelestia .local/state/caelestia .local/share/caelestia;^([^ ]*/)?(caelestia|(quickshell|qs) .*caelestia);caelestia-shell caelestia-cli;
dms;.config/DankMaterialShell .local/state/DankMaterialShell .cache/DankMaterialShell;^([^ ]*/)?(dms|(quickshell|qs) .*(dms|DankMaterialShell));dms-shell-bin dms-shell-git dms-shell dankmaterialshell;dms
illogical-impulse;.config/illogical-impulse;^([^ ]*/)?(quickshell|qs) .*-c ii( |$);illogical-impulse-quickshell-git;"

# only stopped, never uninstalled: bars and notification daemons (our shell has its own)
others="waybar hyprpanel ags eww mako dunst swaync swayosd-server"

# any Quickshell started with a config of its own (-c name / -p path) is not ours
qsother='^([^ ]*/)?(quickshell|qs) (.* )?(-c|--config|-p|--path)( |$)'

others_run() {
    nl='
'
    ifs_save=$IFS
    set -f   # the regexes above contain * and [ : no pathname expansion in here

    found=""; sub=""; running=""

    IFS=$nl
    for line in $shells; do
        IFS=";"; set -- $line; IFS=$ifs_save
        name=$1; dirs=$2; proc=$3; pk=$4
        hit=""
        for d in $dirs; do [ -e "$HOME/$d" ] && hit=1; done
        [ -n "$proc" ] && pgrep -f -- "$proc" >/dev/null 2>&1 && hit=1
        if command -v pacman >/dev/null 2>&1; then
            for p in $pk; do pacman -Q "$p" >/dev/null 2>&1 && hit=1; done
        fi
        if [ -n "$hit" ]; then found="$found $name"; say "found: $name"; fi
        IFS=$nl
    done
    IFS=$ifs_save

    # Quickshell configs of other shells living next to ours (~/.config/quickshell/<name>/shell.qml)
    for f in "$cfg"/quickshell/*/shell.qml; do
        [ -e "$f" ] || continue
        d=$(dirname "$f"); n=$(basename "$d")
        [ -e "$here/quickshell/$n/shell.qml" ] && continue
        sub="$sub $d"; say "found: another Quickshell config in quickshell/$n"
    done

    runqs=$(pgrep -af -- "$qsother" 2>/dev/null || true)
    if [ -n "$runqs" ]; then
        found="$found quickshell-other"
        say "found: a Quickshell shell is running with its own config:"
        printf '%s\n' "$runqs" | sed 's/^/        /'
    fi
    for p in $others; do pgrep -x "$p" >/dev/null 2>&1 && running="$running $p"; done
    [ -n "$running" ] && say "running and will be stopped:$running"

    # autostart lines of other shells in the compositor files (light mode leaves them: tell the user)
    auto=$(grep -lisE 'noctalia|caelestia|dms |DankMaterialShell|hyprpanel|waybar|ags ' "$cfg"/niri/*.kdl "$cfg"/hypr/*.lua "$cfg"/hypr/*.conf 2>/dev/null || true)
    if [ -n "$auto" ]; then
        if [ "$mode" = light ]; then
            warn "these files start other shells and light mode does not touch them: $(printf '%s' "$auto" | tr '\n' ' ')"
        else
            say "they also start from: $(printf '%s' "$auto" | tr '\n' ' ') (full mode replaces them)"
        fi
    fi

    if [ -z "$found$sub$running" ]; then
        say "none: nothing to remove"
        set +f; return 0
    fi

    if ! confirm "Remove them? (settings go to the backup, nothing is lost)"; then
        say "skipped: they may fight with this shell (two bars, two notification daemons)"
        set +f; return 0
    fi

    mkdir -p "$bk/removed"
    IFS=$nl
    for line in $shells; do
        IFS=";"; set -- $line; IFS=$ifs_save
        name=$1; dirs=$2; proc=$3; pk=$4; unit=$5
        case " $found " in *" $name "*) ;; *) IFS=$nl; continue ;; esac
        say "$name: stopping"
        [ -n "$proc" ] && pkill -f -- "$proc" 2>/dev/null || true
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
            if [ -n "$inst" ]; then
                say "$name: uninstalling$inst"
                sudo pacman -Rns --noconfirm $inst || warn "could not uninstall"
            fi
        fi
        IFS=$nl
    done
    IFS=$ifs_save

    pkill -f -- "$qsother" 2>/dev/null || true
    for p in $running; do pkill -x "$p" 2>/dev/null || true; done
    for d in $sub; do
        n=$(basename "$d"); mkdir -p "$bk/removed/quickshell"
        mv "$d" "$bk/removed/quickshell/$n"; say "moved quickshell/$n to the backup"
    done
    [ -n "$running" ] && say "stopped:$running"

    # leftovers of these shells in the compositor folders
    for f in niri/noctalia.kdl niri/dms hypr/noctalia.lua hypr/noctalia hypr/dms; do
        if [ -e "$cfg/$f" ]; then
            mkdir -p "$bk/removed/$(dirname "$f")"
            mv "$cfg/$f" "$bk/removed/$f"; say "moved $f to the backup"
        fi
    done
    if [ -z "$purge" ] && [ -n "$found" ]; then say "their packages stay installed (use --purge to uninstall them too)"; fi
    set +f
    return 0
}
