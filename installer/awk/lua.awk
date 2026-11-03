# lua.awk: keybind helper for Hyprland Lua configs (hl.bind(...)).
#
#   -v op=keys      print the normalized keys bound in the input
#   -v op=filter    copy the input, dropping every hl.bind(...) statement whose key
#                   is listed in the file "used"; dropped keys are appended to
#                   "skipfile" (with "tag")
#
# Understood key forms:  "SUPER + SHIFT + E"   mainMod .. " + Q"   "SUPER+Q"
# A key built with anything else (a loop variable, a function call) is ignored:
# it is never reported as used and never dropped.

function norm(t,   n, a, i, j, m, v, x, mods, out) {
    t = tolower(t)
    n = split(t, a, "+")
    m = 0
    for (i = 1; i < n; i++) {
        x = a[i]
        if (x == "super" || x == "win" || x == "meta" || x == "mainmod") x = "mod"
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

# the line without its "--" comment (quotes respected)
function nocomment(s,   i, c, q) {
    q = ""
    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (q != "") {
            if (c == "\\") i++
            else if (c == q) q = ""
            continue
        }
        if (c == "\"" || c == sq) { q = c; continue }
        if (c == "-" && substr(s, i + 1, 1) == "-") return substr(s, 1, i - 1)
    }
    return s
}

# same length as the input, but the inside of every string becomes "_"
function blank(s,   i, c, q, out) {
    q = ""; out = ""
    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (q != "") {
            if (c == "\\") { out = out "__"; i++; continue }
            if (c == q) { q = ""; out = out c } else out = out "_"
            continue
        }
        if (c == "\"" || c == sq) q = c
        out = out c
    }
    return out
}

function cnt(s, ch,   n, i) {
    n = 0
    for (i = 1; i <= length(s); i++) if (substr(s, i, 1) == ch) n++
    return n
}

# first argument of a call, given the text right after "hl.bind("
function firstarg(t,   i, c, q, d) {
    q = ""; d = 0
    for (i = 1; i <= length(t); i++) {
        c = substr(t, i, 1)
        if (q != "") {
            if (c == "\\") i++
            else if (c == q) q = ""
            continue
        }
        if (c == "\"" || c == sq) { q = c; continue }
        if (c == "(" || c == "{" || c == "[") d++
        else if (c == ")" || c == "}" || c == "]") { if (d == 0) return substr(t, 1, i - 1); d-- }
        else if (c == "," && d == 0) return substr(t, 1, i - 1)
    }
    return t
}

# normalized key of a first argument, or "" if it is not made only of strings and mainMod/mod/super
function keyof(a,   r, b) {
    r = a
    gsub("\"[^\"]*\"", "", r)
    gsub(sq "[^" sq "]*" sq, "", r)
    gsub(/\.\./, "", r)
    gsub(/[ \t]/, "", r)
    r = tolower(r)
    gsub(/mainmod|mod|super/, "", r)
    if (r != "") return ""
    b = a
    gsub(/\.\./, "", b)
    gsub("[\"" sq " \t]", "", b)
    b = tolower(b)
    gsub(/mainmod/, "mod", b)
    if (b == "") return ""
    return norm(b)
}

function finish(   i, k) {
    i = index(all, "hl.bind(")
    k = keyof(firstarg(substr(all, i + 8)))
    if (op == "keys") {
        if (k != "") print k
    } else {
        if (k != "" && (k in U)) {
            print tag ": " k >> skipfile
        } else printf "%s", stmt
    }
    collect = 0; stmt = ""; all = ""
}

BEGIN {
    sq = sprintf("%c", 39)
    collect = 0; stmt = ""; all = ""; pd = 0
    if (used != "") while ((getline l < used) > 0) U[l] = 1
}

{
    raw = $0
    nc = nocomment(raw)
    b = blank(nc)

    if (!collect) {
        pos = index(b, "hl.bind(")
        if (pos == 0) { if (op == "filter") print raw; next }
        collect = 1; stmt = ""; all = ""; pd = 0
        part = substr(b, pos)
        all = substr(nc, pos)
    } else {
        part = b
        all = all " " nc
    }
    stmt = stmt raw "\n"
    pd += cnt(part, "(") - cnt(part, ")")
    if (pd <= 0) finish()
}

END {
    if (collect && op == "filter") printf "%s", stmt
}
