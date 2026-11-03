# shellcheck shell=sh
# Light mode: YOUR niri / Hyprland config stays yours. The installer
#   - copies our binds file next to it (quickshell.kdl / quickshell-binds.lua),
#     WITHOUT the keys your config already uses;
#   - adds one small managed block at the end of your config (the include/require
#     lines and the autostart), between two marker comments, nothing else;
#   - checks the result (niri validate / luac) and puts your file back if it broke.
# Running it again updates the block; there are never duplicates.

nl='
'

# add LINE: append to $body unless $rest (your config without our block) already has it
add() {
    if printf '%s\n' "$rest" | grep -qF -- "$1"; then return 0; fi
    body="${body:+$body$nl}$1"
    return 0
}

add_lines() {
    old=$IFS; IFS=$nl; set -f
    for l in $1; do add "$l"; done
    set +f; IFS=$old
    return 0
}

# ── niri ──
light_niri() {
    s="$here/niri"; d="$cfg/niri"; f="$d/config.kdl"
    B="// >>> quickshell-dots (managed block, do not edit) >>>"
    E="// <<< quickshell-dots <<<"

    if [ ! -f "$f" ]; then
        warn "niri: $f not found, skipped. Light mode adds lines to an existing config: create one, or use --full"
        return 0
    fi
    say "niri (light): a few lines in $f, binds in $d/quickshell.kdl"

    # keys you already use (everything in ~/.config/niri/*.kdl except our own file)
    used=$(mktemp)
    for k in "$d"/*.kdl; do
        [ -f "$k" ] || continue
        [ "$k" = "$d/quickshell.kdl" ] && continue
        block_strip "$k" "$B" "$E" | awk -v op=keys -f "$lib/awk/kdl.awk"
    done | sort -u >"$used"

    backup "$d/quickshell.kdl"; backup "$f"
    awk -v op=filter -v used="$used" -v skipfile="$skipfile" -v tag=niri \
        -f "$lib/awk/kdl.awk" "$s/quickshell.kdl" >"$d/quickshell.kdl.tmp"
    mv "$d/quickshell.kdl.tmp" "$d/quickshell.kdl"
    rm -f "$used"

    # files the shell writes by itself: created only if missing
    for x in quickshell-tweaks.kdl quickshell-outputs.kdl; do
        [ -e "$d/$x" ] || cp "$s/$x" "$d/$x"
    done

    # the block: same include / autostart lines our full config uses, minus what you already have
    rest=$(block_strip "$f" "$B" "$E" | grep -vE '^[[:space:]]*//' || true)
    body=""
    incs=$(pick '^[[:space:]]*include[[:space:]]' "$s/config.kdl" | grep quickshell || true)
    if [ -z "$incs" ]; then
        incs='include "quickshell.kdl"'
        if ! grep -q 'quickshell-tweaks' "$s/quickshell.kdl"; then
            incs="$incs${nl}include \"quickshell-tweaks.kdl\"${nl}include \"quickshell-outputs.kdl\""
        fi
    fi
    add_lines "$incs"
    if ! printf '%s\n%s\n' "$rest" "$(cat "$d/quickshell.kdl")" | grep -qE 'spawn-at-startup.*"(quickshell|qs)"'; then
        sp=$(pick 'spawn-at-startup.*"(quickshell|qs)"' "$s/config.kdl" | head -n 1)
        default='spawn-at-startup "quickshell"'
        add "${sp:-$default}"
    fi
    block_set "$f" "$B" "$E" "$body"
    if [ -n "$body" ]; then say "niri: added to config.kdl:"; printf '%s\n' "$body" | sed 's/^/        /'
    else say "niri: config.kdl already had everything"; fi

    if command -v niri >/dev/null 2>&1; then
        if niri validate -c "$f" >/dev/null 2>&1; then
            say "niri: config.kdl is valid"
        else
            warn "niri: validation failed, your config.kdl was put back as it was"
            cp "$bk/niri/config.kdl" "$f"
        fi
    fi
    return 0
}

# ── Hyprland (Lua) ──
light_hypr() {
    s="$here/hypr"; d="$cfg/hypr"; f="$d/hyprland.lua"
    B="-- >>> quickshell-dots (managed block, do not edit) >>>"
    E="-- <<< quickshell-dots <<<"

    if [ ! -f "$f" ]; then
        warn "Hyprland: $f not found, skipped. Light mode adds lines to an existing config: create one, or use --full"
        return 0
    fi
    say "Hyprland (light): a few lines in $f, binds in $d/quickshell-binds.lua"

    used=$(mktemp)
    find "$d" -name '*.lua' -type f ! -name quickshell-binds.lua | while IFS= read -r k; do
        block_strip "$k" "$B" "$E" | awk -v op=keys -f "$lib/awk/lua.awk"
    done | sort -u >"$used"

    backup "$d/quickshell-binds.lua"; backup "$f"
    awk -v op=filter -v used="$used" -v skipfile="$skipfile" -v tag=Hyprland \
        -f "$lib/awk/lua.awk" "$s/quickshell-binds.lua" >"$d/quickshell-binds.lua.tmp"
    mv "$d/quickshell-binds.lua.tmp" "$d/quickshell-binds.lua"
    rm -f "$used"

    [ -e "$d/quickshell-outputs.lua" ] || cp "$s/quickshell-outputs.lua" "$d/quickshell-outputs.lua"

    rest=$(block_strip "$f" "$B" "$E" | grep -vE '^[[:space:]]*--' || true)
    body=""
    reqs=$(pick '^[[:space:]]*(require|dofile|loadfile)[[:space:](].*quickshell' "$s/hyprland.lua" || true)
    if [ -z "$reqs" ]; then
        reqs="require(\"quickshell-binds\")${nl}require(\"quickshell-outputs\")"
    fi
    add_lines "$reqs"
    if ! printf '%s\n%s\n' "$rest" "$(cat "$d/quickshell-binds.lua")" | grep -qE 'exec_cmd\("(quickshell|qs)"\)'; then
        ex=$(grep -oE 'hl\.exec_cmd\("(quickshell|qs)"\)' "$s/hyprland.lua" | head -n 1 || true)
        exdef='hl.exec_cmd("qs")'
        ex=${ex:-$exdef}
        add "hl.on(\"hyprland.start\", function() $ex end)"
    fi
    block_set "$f" "$B" "$E" "$body"
    if [ -n "$body" ]; then say "Hyprland: added to hyprland.lua:"; printf '%s\n' "$body" | sed 's/^/        /'
    else say "Hyprland: hyprland.lua already had everything"; fi

    if command -v luac >/dev/null 2>&1; then
        if luac -p "$f" >/dev/null 2>&1; then
            say "Hyprland: hyprland.lua has valid Lua syntax"
        else
            warn "Hyprland: syntax check failed, your hyprland.lua was put back as it was"
            cp "$bk/hypr/hyprland.lua" "$f"
        fi
    fi
    return 0
}

# what was left out because you already use that key
light_report() {
    if [ -s "$skipfile" ]; then
        warn "NOT added, because your config already uses these keys:"
        sort -u "$skipfile" | sed 's/^/        /'
        say "those functions still work from the shell and from the terminal: qs ipc call <target> <function>"
        mkdir -p "$cfg/quickshell"
        sort -u "$skipfile" >"$cfg/quickshell/skipped-binds.txt"
    else
        say "no conflicts: every shortcut of the shell was added"
    fi
    return 0
}
