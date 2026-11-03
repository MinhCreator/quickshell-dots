# shellcheck shell=sh
# Uninstall: takes out what the installer added. Nothing is deleted for good:
# everything goes into a backup folder first. Wallpapers, pywal colors and the
# installed packages are left alone.

uninstall_run() {
    prev_mode=$(state_get mode)
    orig=$(state_get orig)
    step "1/3" "What was installed"
    if [ -f "$state" ]; then say "install mode: ${prev_mode:-unknown}"; else say "no state file: looking at the files directly"; fi

    # niri
    nB="// >>> quickshell-dots (managed block, do not edit) >>>"; nE="// <<< quickshell-dots <<<"
    # Hyprland
    hB="-- >>> quickshell-dots (managed block, do not edit) >>>"; hE="-- <<< quickshell-dots <<<"

    step "2/3" "Removing it"
    pkill -x quickshell 2>/dev/null || true

    f="$cfg/niri/config.kdl"
    if [ -f "$f" ] && grep -qF -- "$nB" "$f"; then
        backup "$f"; block_set "$f" "$nB" "$nE" ""
        say "niri: removed the managed block from config.kdl"
    fi
    for x in quickshell.kdl quickshell-tweaks.kdl quickshell-outputs.kdl; do
        if [ -e "$cfg/niri/$x" ]; then backup "$cfg/niri/$x"; rm -f "$cfg/niri/$x"; say "niri: removed $x (copy in the backup)"; fi
    done

    f="$cfg/hypr/hyprland.lua"
    if [ -f "$f" ] && grep -qF -- "$hB" "$f"; then
        backup "$f"; block_set "$f" "$hB" "$hE" ""
        say "Hyprland: removed the managed block from hyprland.lua"
    fi
    for x in quickshell-binds.lua quickshell-outputs.lua; do
        if [ -e "$cfg/hypr/$x" ]; then backup "$cfg/hypr/$x"; rm -f "$cfg/hypr/$x"; say "Hyprland: removed $x (copy in the backup)"; fi
    done

    if [ -d "$cfg/quickshell" ]; then
        mkdir -p "$bk/removed"
        mv "$cfg/quickshell" "$bk/removed/quickshell"
        say "shell: moved ~/.config/quickshell to the backup"
    fi

    # full mode replaced your configs: offer to put the originals back
    if [ "$prev_mode" = full ] && [ -n "$orig" ] && [ -d "$orig" ]; then
        step "3/3" "Your original compositor configs"
        for rel in niri/config.kdl hypr/hyprland.lua; do
            [ -f "$orig/$rel" ] || continue
            if confirm "Put back your original $rel (saved in $orig)?"; then
                backup "$cfg/$rel"
                mkdir -p "$(dirname "$cfg/$rel")"
                cp "$orig/$rel" "$cfg/$rel"
                say "restored $rel"
            else
                say "left $cfg/$rel as it is (the original is in $orig/$rel)"
            fi
        done
    else
        step "3/3" "Your configs"
        say "nothing to restore: light mode never replaced them"
    fi

    rm -f "$state"
    printf '\n\033[1mDone.\033[0m Reload your compositor to apply it:\n'
    say "niri:     niri msg action load-config-file"
    say "Hyprland: hyprctl reload"
    say "backup of what was removed: $bk"
    return 0
}
