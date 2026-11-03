# shellcheck shell=sh
# Shared helpers: options, output, backup, managed blocks, state file.
# Sourced by install.sh, never run on its own.

cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
bk="$cfg/quickshell-backup-$(date +%Y%m%d-%H%M%S)"
state="$cfg/quickshell-dots.state"

want_niri=""; want_hypr=""; yes=""; nodeps=""; purge=""
mode=""; action="install"; nostart=""; noothers=""

skipfile=$(mktemp)
trap 'rm -f "$skipfile"' EXIT

usage() {
    cat <<'EOF'
quickshell-dots installer (niri + Hyprland, same shortcuts, same styles)

  sh install.sh                 detects niri / Hyprland, asks which mode you want
  sh install.sh --light         light mode: adds a few lines to YOUR configs, skips
                                the keys you already use, replaces nothing
  sh install.sh --full          full mode: installs our niri / Hyprland configs
                                (yours are backed up first)
  sh install.sh --uninstall     removes what the installer added

Which compositor:
  --niri  --hyprland  --all     (default: whatever it finds)

Other options:
  --yes, -y       do not ask anything (default mode becomes --light)
  --no-deps       skip the check for missing programs
  --no-others     do not look for other shells (noctalia, caelestia, DMS...)
  --purge         also uninstall the packages of other shells
  --no-start      do not start the shell at the end
  -h, --help      this text

Everything that gets replaced is saved first in ~/.config/quickshell-backup-DATE
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --niri) want_niri=1 ;;
            --hyprland|--hypr) want_hypr=1 ;;
            --all) want_niri=1; want_hypr=1 ;;
            --light) mode=light ;;
            --full) mode=full ;;
            --uninstall) action=uninstall ;;
            --yes|-y) yes=1 ;;
            --no-deps) nodeps=1 ;;
            --no-others) noothers=1 ;;
            --purge) purge=1 ;;
            --no-start) nostart=1 ;;
            -h|--help) usage; exit 0 ;;
            *) echo "unknown option: $1"; echo; usage; exit 1 ;;
        esac
        shift
    done
}

step() { printf '\n\033[1m[%s]\033[0m %s\n' "$1" "$2"; }
say()  { printf '    %s\n' "$*"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$*"; }

# confirm "question": 0 = yes (also with --yes or when there is no terminal)
confirm() {
    [ -n "$yes" ] && return 0
    printf '    %s [Y/n] ' "$1"
    r=y
    read -r r </dev/tty 2>/dev/null || r=y
    case "$r" in n|N|no|NO) return 1 ;; esac
    return 0
}

# backup PATH: copy it into the backup folder (only the first time in this run,
# so the backup always holds the original)
backup() {
    [ -e "$1" ] || return 0
    rel=${1#"$cfg"/}
    [ -e "$bk/$rel" ] && return 0
    mkdir -p "$bk/$(dirname "$rel")"
    cp -a "$1" "$bk/$rel"
    return 0
}

# put SRC DST: copy with question + backup (full mode)
put() {
    if [ -e "$2" ] && ! confirm "$2 exists and will be replaced (backup saved). Continue?"; then
        say "skipped $2"; return 0
    fi
    backup "$2"
    cp "$1" "$2"
}

have() {
    case "$1" in
        awww) command -v awww >/dev/null 2>&1 || command -v swww >/dev/null 2>&1 ;;
        magick) command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 ;;
        *) command -v "$1" >/dev/null 2>&1 ;;
    esac
}

detect_compositors() {
    [ -n "$want_niri$want_hypr" ] && return 0
    [ -d "$cfg/niri" ] && want_niri=1
    [ -d "$cfg/hypr" ] && want_hypr=1
    if [ -z "$want_niri$want_hypr" ]; then
        command -v niri >/dev/null 2>&1 && want_niri=1
        command -v Hyprland >/dev/null 2>&1 && want_hypr=1
    fi
    if [ -z "$want_niri$want_hypr" ]; then
        echo "niri / Hyprland not found: use --niri, --hyprland or --all"
        exit 1
    fi
    return 0
}

# ── managed blocks: the only thing light mode writes inside YOUR files ──
# block_strip FILE BEGIN END  -> FILE without the managed block, on stdout
block_strip() {
    awk -v b="$2" -v e="$3" '$0==b{skip=1;next} $0==e{skip=0;next} !skip{print}' "$1"
}

# block_set FILE BEGIN END BODY  -> replaces (or adds) the block; empty BODY removes it.
# Writes through the existing file so symlinks (dotfile managers) keep working.
block_set() {
    f=$1; b=$2; e=$3; body=$4
    tmp=$(mktemp)
    block_strip "$f" "$b" "$e" >"$tmp"
    if [ -n "$body" ]; then
        { printf '%s\n' "$b"; printf '%s\n' "$body"; printf '%s\n' "$e"; } >>"$tmp"
    fi
    cat "$tmp" >"$f"
    rm -f "$tmp"
}

# pick REGEX FILE...  -> matching lines, trimmed
pick() {
    re=$1; shift
    cat "$@" 2>/dev/null | grep -E -- "$re" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' || true
}

# ── state, to know what to undo ──
state_get() { [ -f "$state" ] && sed -n "s/^$1=//p" "$state" | head -n 1; return 0; }

state_write() {
    orig=$(state_get orig)
    [ -z "$orig" ] && orig=$bk
    {
        echo "mode=$mode"
        echo "niri=$want_niri"
        echo "hypr=$want_hypr"
        echo "orig=$orig"
        echo "last=$bk"
    } >"$state"
}
