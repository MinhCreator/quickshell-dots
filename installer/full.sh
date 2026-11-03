# shellcheck shell=sh
# Full mode: our own niri / Hyprland configs replace yours (always asking first,
# always with a backup). This is the setup the screenshots show.

full_niri() {
    say "niri (full) -> $cfg/niri (config.kdl, quickshell.kdl)"
    mkdir -p "$cfg/niri"
    put "$here/niri/config.kdl" "$cfg/niri/config.kdl"
    put "$here/niri/quickshell.kdl" "$cfg/niri/quickshell.kdl"
    # managed by the shell: created only if missing
    for f in quickshell-tweaks.kdl quickshell-outputs.kdl; do
        [ -e "$cfg/niri/$f" ] || cp "$here/niri/$f" "$cfg/niri/$f"
    done
    # leftovers of older setups
    for f in config.kdl.old backdrop.fish noctalia.kdl; do
        if [ -e "$cfg/niri/$f" ]; then backup "$cfg/niri/$f"; rm -f "$cfg/niri/$f"; fi
    done
    return 0
}

full_hypr() {
    say "Hyprland (full) -> $cfg/hypr (hyprland.lua, quickshell-binds.lua)"
    mkdir -p "$cfg/hypr"
    put "$here/hypr/hyprland.lua" "$cfg/hypr/hyprland.lua"
    backup "$cfg/hypr/quickshell-binds.lua"
    cp "$here/hypr/quickshell-binds.lua" "$cfg/hypr/quickshell-binds.lua"
    [ -e "$cfg/hypr/quickshell-outputs.lua" ] || cp "$here/hypr/quickshell-outputs.lua" "$cfg/hypr/quickshell-outputs.lua"
    for f in monitors.conf workspaces.conf monitors.lua scripts/record.sh scripts/qs-record.sh pywalfox-autoupdate.sh; do
        if [ -e "$cfg/hypr/$f" ]; then backup "$cfg/hypr/$f"; rm -f "$cfg/hypr/$f"; fi
    done
    return 0
}
