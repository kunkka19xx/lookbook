#!/usr/bin/env bash
# Checks every example with Look's own parser, so this repo cannot drift from
# what Look actually accepts. Reimplementing the format here would only teach us
# what a second parser thinks.
#
#   ./scripts/check.sh
#
# Needs bash, not sh: an example folder may hold several .toml files.
#
# Set PARSER to an already-built parse_check to skip the build:
#   PARSER=../look/core/target/debug/examples/parse_check ./scripts/check.sh
set -euo pipefail

readonly LOOK_REPO="https://github.com/kunkka19xx/look"
readonly LOOK_CHECKOUT="${LOOK_CHECKOUT:-.look-src}"
readonly EXAMPLES_DIR="examples"
readonly WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

failures=0

fail() {
    printf '  FAIL  %s\n' "$1"
    failures=$((failures + 1))
}

# The parser: whatever was handed to us, else a sibling checkout, else clone one.
resolve_parser() {
    if [ -n "${PARSER:-}" ]; then
        printf '%s' "$PARSER"
        return
    fi
    if [ ! -d "$LOOK_CHECKOUT" ]; then
        git clone --depth 1 "$LOOK_REPO" "$LOOK_CHECKOUT" >&2
    fi
    cargo build --manifest-path "$LOOK_CHECKOUT/core/Cargo.toml" \
        -p look-sources --example parse_check >&2
    printf '%s' "$LOOK_CHECKOUT/core/target/debug/examples/parse_check"
}

parser="$(resolve_parser)"
if [ ! -x "$parser" ]; then
    echo "no parser at $parser" >&2
    exit 1
fi

echo "Checking examples with $parser"
echo

# 1. Every example parses on its own, and owns every id it declares.
#
# A folder is a topic and may hold several .toml files, so all of them are
# checked and all of them must carry the folder's name: they land together in
# one flat directory, where a second `hosts.toml` would overwrite the first.
#
# Each example is copied to a directory of its own first: Look reads a flat
# directory, so a README or a bin/ sitting beside the .toml is not what it
# would ever see.
for dir in "$EXAMPLES_DIR"/*/; do
    name="$(basename "$dir")"
    printf '%s\n' "$name"

    tomls=("$dir"*.toml)
    if [ ! -e "${tomls[0]}" ]; then
        fail "$name has no .toml file"
        continue
    fi

    for toml in "${tomls[@]}"; do
        file="$(basename "$toml")"
        case "$file" in
            "$name".toml | "$name"-*.toml) ;;
            *) fail "$file must be $name.toml or start with \"$name-\"" ;;
        esac
    done

    solo="$WORK_DIR/solo-$name"
    mkdir -p "$solo"
    cp "${tomls[@]}" "$solo/"

    output="$("$parser" "$solo")"

    if printf '%s\n' "$output" | grep -q '^problem:'; then
        printf '%s\n' "$output" | grep '^problem:' | sed 's/^/  /'
        fail "$name does not parse cleanly"
        continue
    fi

    # Every block id prefixed with the example name, so ten installed examples
    # cannot shadow each other.
    while read -r id; do
        [ -n "$id" ] || continue
        case "$id" in
            "$name" | "$name"-*) ;;
            *) fail "block [$id] must be [$name] or start with \"$name-\"" ;;
        esac
    done <<< "$(printf '%s\n' "$output" | awk '/^block /{print $2}')"

    printf '  ok    %s file(s), %s block(s)\n' \
        "${#tomls[@]}" \
        "$(printf '%s\n' "$output" | grep -c '^block ' || true)"
done

echo

# The template is what every new example is copied from, so it has to parse
# like one. It lives outside examples/ because it is not one.
echo "template"
template="$WORK_DIR/template"
mkdir -p "$template"
cp template/*.toml "$template/"
template_output="$("$parser" "$template")"
if printf '%s\n' "$template_output" | grep -q '^problem:'; then
    printf '%s\n' "$template_output" | grep '^problem:' | sed 's/^/  /'
    fail "template does not parse"
else
    printf '  ok    %s block(s)\n' \
        "$(printf '%s\n' "$template_output" | grep -c '^block ' || true)"
fi

echo

# 2. All of them installed at once, which is what an enthusiastic user does.
#    A duplicate id or a `then` naming a block nobody declares shows up here.
all="$WORK_DIR/all"
mkdir -p "$all"
find "$EXAMPLES_DIR" -mindepth 2 -maxdepth 2 -name '*.toml' -exec cp {} "$all/" \;

echo "every example installed together"
combined="$("$parser" "$all")"
if printf '%s\n' "$combined" | grep -q '^problem:'; then
    printf '%s\n' "$combined" | grep '^problem:' | sed 's/^/  /'
    fail "the examples collide when installed together"
else
    printf '  ok    %s block(s), no collisions\n' \
        "$(printf '%s\n' "$combined" | grep -c '^block ' || true)"
fi

echo

# 3. Paperwork every example owes its reader.
#
# Parsing proves the file is valid, never that the commands work. What is
# checkable from here is that the reader is told enough to judge for themselves:
# above all, which platforms the author actually ran it on.
echo "readmes"
for dir in "$EXAMPLES_DIR"/*/; do
    name="$(basename "$dir")"
    readme="$dir/README.md"

    if [ ! -f "$readme" ]; then
        fail "$name has no README.md"
        continue
    fi

    platforms="$(grep -m1 '^\*\*Platforms\.\*\*' "$readme" || true)"
    if [ -z "$platforms" ]; then
        fail "$name: README needs a line starting \"**Platforms.**\" naming the OSes you tested"
    elif ! printf '%s' "$platforms" | grep -Eqi 'macos|linux|windows'; then
        fail "$name: Platforms line names no OS (macOS, Linux, Windows)"
    fi

    # An example nobody can find is an example nobody runs.
    grep -q "examples/$name" README.md || fail "$name is missing from the index table in README.md"

    for script in "$dir"bin/*; do
        [ -e "$script" ] || continue
        [ -x "$script" ] || fail "$script is not executable (chmod +x)"
        head -1 "$script" | grep -q '^#!' || fail "$script has no shebang"
    done
done
printf '  ok    %s example(s) documented\n' "$(find "$EXAMPLES_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"

if [ "$failures" -gt 0 ]; then
    printf '%s check(s) failed\n' "$failures"
    exit 1
fi
echo "all good"
