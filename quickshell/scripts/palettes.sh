#!/bin/sh
# Prints "path<TAB>pywal-json" for each wallpaper.
# wal runs with a fake HOME: pywal always writes to $HOME/.cache/wal,
# so the real system palette is left untouched.
dir="${1:-$(sh "$(dirname "$0")/wallpaper-dir.sh")}"
cache="$HOME/.cache/quickshell-palettes"
fakehome="$cache/home"
mkdir -p "$cache" "$fakehome"

for img in "$dir"/*; do
    [ -f "$img" ] || continue
    case "$img" in
        *.jpg|*.jpeg|*.png|*.webp|*.JPG|*.JPEG|*.PNG|*.WEBP) ;;
        *) continue ;;
    esac

    key=$(printf '%s' "$img" | md5sum | cut -d' ' -f1)
    out="$cache/$key.json"

    if [ ! -s "$out" ] || [ "$img" -nt "$out" ]; then
        HOME="$fakehome" wal -i "$img" -n -s -t -e -q >/dev/null 2>&1 \
            && cp "$fakehome/.cache/wal/colors.json" "$out"
    fi

    [ -s "$out" ] && printf '%s\t%s\n' "$img" "$(tr -d '\n' < "$out")"
done
