# shellcheck shell=sh
# Programs the shell needs: check and (on Arch) offer to install.

# command:package (Arch). awww can be swww, magick can be convert.
deps="qs:quickshell awww:awww wal:python-pywal jq:jq grim:grim slurp:slurp wf-recorder:wf-recorder
ffmpeg:ffmpeg wpctl:wireplumber playerctl:playerctl brightnessctl:brightnessctl cava:cava
cliphist:cliphist wl-mirror:wl-mirror magick:imagemagick notify-send:libnotify
inotifywait:inotify-tools pywalfox:python-pywalfox xdg-user-dir:xdg-user-dirs"

deps_check() {
    miss_pkg=""
    for d in $deps; do
        c=${d%%:*}; p=${d#*:}
        if have "$c"; then say "ok       $c"
        else say "MISSING  $c  (package: $p)"; miss_pkg="$miss_pkg $p"; fi
    done

    if [ -z "$miss_pkg" ]; then
        say "everything is installed"
        return 0
    fi
    if ! command -v pacman >/dev/null 2>&1; then
        say "this is not Arch: install these with your package manager:$miss_pkg"
        return 0
    fi
    if ! confirm "Install the missing packages now?"; then
        say "skipped: install later:$miss_pkg"
        return 0
    fi

    repo=""; aur=""
    for p in $miss_pkg; do
        if pacman -Si "$p" >/dev/null 2>&1; then repo="$repo $p"; else aur="$aur $p"; fi
    done
    if [ -n "$repo" ]; then
        say "installing from the official repositories:$repo"
        # shellcheck disable=SC2086
        sudo pacman -S --needed --noconfirm $repo || warn "pacman failed: continuing"
    fi
    if [ -n "$aur" ]; then
        helper=""
        command -v paru >/dev/null 2>&1 && helper=paru
        [ -z "$helper" ] && command -v yay >/dev/null 2>&1 && helper=yay
        if [ -n "$helper" ]; then
            say "installing from the AUR with $helper:$aur"
            # shellcheck disable=SC2086
            $helper -S --needed --noconfirm $aur || warn "$helper failed: continuing"
        else
            say "from the AUR (no yay/paru found, install them by hand):$aur"
        fi
    fi
    return 0
}

# Pywalfox: native host registration (safe to repeat) + reminder for the add-on
pywalfox_setup() {
    if command -v pywalfox >/dev/null 2>&1; then
        say "Firefox: registering the Pywalfox native host (safe to repeat)"
        if pywalfox install >/dev/null 2>&1; then say "registered"; else warn "pywalfox install failed: run it by hand"; fi
    else
        say "Firefox: Pywalfox is not installed (package python-pywalfox, then run: pywalfox install)"
    fi
    say "Firefox also needs the add-on, installed once from the browser:"
    say "  https://addons.mozilla.org/firefox/addon/pywalfox/"
    return 0
}
