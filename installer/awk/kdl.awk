# kdl.awk: keybind helper for niri (KDL) configs.
#
#   -v op=keys      print the normalized keys bound in the input
#   -v op=filter    copy the input, dropping every bind whose key is listed in the
#                   file "used"; dropped keys are appended to "skipfile" (with "tag")
#
# Keys are normalized so that Mod+Shift+E, shift+super+e and Super+Shift+E match.

function norm(t,   n, a, i, j, m, v, x, mods, out) {
    t = tolower(t)
    n = split(t, a, "+")
    m = 0
    for (i = 1; i < n; i++) {
        x = a[i]
        if (x == "super" || x == "win" || x == "mod4") x = "mod"
        if (x == "control") x = "ctrl"
        mods[++m] = x
    }
    for (i = 2; i <= m; i++) {
        v = mods[i]; j = i - 1
        while (j >= 1 && mods[j] > v) { mods[j + 1] = mods[j]; j-- }
        mods[j + 1] = v
    }
    out = ""
    for (i = 1; i <= m; i++) out = out mods[i] "+"
    return out a[n]
}

# the line without comments and without the content of strings (so braces in them do not count)
function strip(s,   out, i, c, q) {
    out = ""; q = 0
    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (q) {
            if (c == "\\") i++
            else if (c == "\"") q = 0
            continue
        }
        if (c == "\"") { q = 1; continue }
        if (c == "/" && substr(s, i + 1, 1) == "/") break
        out = out c
    }
    return out
}

function cnt(s, ch,   n, i) {
    n = 0
    for (i = 1; i <= length(s); i++) if (substr(s, i, 1) == ch) n++
    return n
}

BEGIN {
    depth = 0; inb = 0; skip = 0; bd = 0; sd = 0
    if (used != "") while ((getline l < used) > 0) U[l] = 1
}

{
    raw = $0
    s = strip(raw)
    isbind = 0; tok = ""; rawtok = ""

    if (!inb && s ~ /^[ \t]*binds[ \t]*[{]/) {
        inb = 1; bd = depth
    } else if (inb && !skip && depth == bd + 1 && s ~ /^[ \t]*[^ \t\/{}]/) {
        # a bind line: the first word is the key ("/-" lines, disabled by slashdash, never match)
        rawtok = s
        sub(/^[ \t]+/, "", rawtok)
        sub(/[ \t{].*$/, "", rawtok)
        tok = norm(rawtok)
        isbind = 1
    }

    if (op == "keys") {
        if (isbind) print tok
    } else {
        if (isbind && (tok in U)) {
            skip = 1; sd = depth
            print tag ": " rawtok >> skipfile
        }
        if (!skip) print raw
    }

    depth += cnt(s, "{") - cnt(s, "}")
    if (skip && depth <= sd) skip = 0
    if (inb && depth <= bd) inb = 0
}
