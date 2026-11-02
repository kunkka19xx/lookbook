#!/usr/bin/env bash
# Builds index.json from sources/*/meta.toml plus what is on disk.
#
#   make index          regenerate it
#   make index CHECK=1  fail if it is out of date, for CI
#
# The catalog Look reads to list these without cloning the repo. Everything a
# browser shows before you install comes from here: the name, the sentence, the
# platforms, what you need installed first.
#
# Derived rather than declared: the `.toml` filenames, the `bin/` scripts, and
# a hash of both. meta.toml says what only a person can say; this fills in what
# the folder already knows, so the two cannot drift.
#
# No jq, no python. The schema is small and fixed, which is what makes sed
# enough, and keeps this repo usable with nothing but git and make.
set -euo pipefail

readonly INDEX="index.json"
# What Look resolves a relative path against. Pinned to a branch on purpose: a
# published catalog entry has to keep meaning the same thing.
readonly BASE="https://raw.githubusercontent.com/kunkka19xx/lookbook/main/"
# The same files as pages a person can read. `base` serves raw bytes, which is
# right for a .toml Look is about to parse and wrong for a README someone
# clicked to read: GitHub renders this one, images, anchors and all.
readonly WEB="https://github.com/kunkka19xx/lookbook/blob/main/"

# A scalar: name = "Dev projects" -> Dev projects
scalar() {
    sed -n "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*\"\(.*\)\"[[:space:]]*$/\1/p" "$1" | head -1
}

# An array, already JSON: platforms = ["macos", "linux"] -> "macos", "linux"
# Lifted verbatim because the TOML and JSON spellings agree, and re-quoting it
# by hand is how a trailing comma gets in.
array() {
    sed -n "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*\[\(.*\)\][[:space:]]*$/\1/p" "$1" | head -1
}

# Quoted basenames of everything matching a glob, comma separated. Nothing at
# all when the glob matches nothing, so the caller's [] stays empty.
quoted() {
    local first=1 name
    for path in "$@"; do
        [ -e "$path" ] || continue
        name="$(basename "$path")"
        [ "$name" = "meta.toml" ] && continue
        [ $first -eq 1 ] || printf ', '
        printf '"%s"' "$name"
        first=0
    done
}

# macOS ships shasum, Linux sha256sum. Neither ships both.
sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum | cut -d' ' -f1
    else
        shasum -a 256 | cut -d' ' -f1
    fi
}

# Every file the install would copy, hashed in one pass in a fixed order, so
# the same tree always gives the same digest. What a later "update available"
# badge compares against.
digest() {
    find "$1" -type f \( -name '*.toml' -o -path '*/bin/*' \) ! -name 'meta.toml' \
        | LC_ALL=C sort \
        | xargs cat 2>/dev/null \
        | sha256
}

generate() {
    printf '{\n'
    printf '  "version": 1,\n'
    printf '  "base": "%s",\n' "$BASE"
    printf '  "web": "%s",\n' "$WEB"
    printf '  "sources": [\n'

    local first=1 dir id meta
    for dir in sources/*/; do
        dir="${dir%/}"
        id="$(basename "$dir")"
        meta="$dir/meta.toml"
        [ -f "$meta" ] || { echo "index: no $meta" >&2; exit 1; }

        [ $first -eq 1 ] || printf ',\n'
        printf '    {\n'
        printf '      "id": "%s",\n' "$id"
        printf '      "name": "%s",\n' "$(scalar "$meta" name)"
        printf '      "description": "%s",\n' "$(scalar "$meta" description)"
        printf '      "platforms": [%s],\n' "$(array "$meta" platforms)"
        printf '      "look": "%s",\n' "$(scalar "$meta" look)"
        printf '      "requires": [%s],\n' "$(array "$meta" requires)"
        printf '      "files": [%s],\n' "$(quoted "$dir"/*.toml)"
        printf '      "bin": [%s],\n' "$(quoted "$dir"/bin/*)"
        printf '      "readme": "%s/README.md",\n' "$dir"
        printf '      "path": "%s/",\n' "$dir"
        printf '      "hash": "sha256:%s"\n' "$(digest "$dir")"
        printf '    }'
        first=0
    done

    printf '\n  ]\n'
    printf '}\n'
}

if [ "${CHECK:-}" = "1" ]; then
    if ! generate | diff -q - "$INDEX" >/dev/null 2>&1; then
        echo "problem: $INDEX is out of date, run: make index" >&2
        exit 1
    fi
    echo "$INDEX is up to date"
else
    generate > "$INDEX"
    echo "wrote $INDEX ($(grep -c '"id":' "$INDEX") sources)"
fi
