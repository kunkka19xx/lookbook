#!/usr/bin/env bash
# Checks every example with Look's own parser, so this repo cannot drift from
# what Look actually accepts. Reimplementing the format here would only teach us
# what a second parser thinks.
#
#   ./scripts/check.sh              every example
#   ./scripts/check.sh tmux         just examples/tmux
#
# Needs bash, not sh: an example folder may hold several .toml files.
#
# Set PARSER to an already-built parse_check to skip the build:
#   PARSER=../look/core/target/debug/examples/parse_check ./scripts/check.sh
#
# This covers every line of CONTRIBUTING's checklist except the two that need a
# human: that you installed the example and used it, and that a command only one
# OS understands is labelled as such. Neither is decidable from the text, and
# they are the two that actually catch a broken example, so the walkthrough in
# CONTRIBUTING is still the part that matters.
set -euo pipefail

readonly LOOK_REPO="https://github.com/kunkka19xx/look"
readonly LOOK_CHECKOUT="${LOOK_CHECKOUT:-.look-src}"
readonly EXAMPLES_DIR="examples"
readonly INDEX="README.md"
readonly WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Nothing in here is a binary, so anything larger than this is a mistake: what
# the repo is for is a handful of small text files people read before copying.
readonly MAX_FILE_BYTES=65536

# Media committed before the "link a GIF, do not commit it" rule was written.
# Git keeps every version of a binary forever, so deleting the file now would
# not shrink a single existing clone; the exception goes away when the GIF is
# re-hosted somewhere else and the README links it from there.
readonly GRANDFATHERED="examples/tmux/open-in-tmux.gif"

# CONTRIBUTING: "No hard-coded home directory. Write ~/dev, never /Users/you."
readonly HOME_DIR_RE='/Users/|/home/[a-z]|[Cc]:\\+[Uu]sers'

# CONTRIBUTING: "No placeholder is quoted by you." Look shell-escapes every
# substitution, so a second layer of quotes is what breaks it.
#
# The names are spelled out rather than matched as {anything} because a looser
# pattern hits text that is not a placeholder at all: the tmux example's `run`
# line embeds '{"id":"#{session_name}"}', which is tmux format syntax inside
# JSON and entirely correct.
#
# The optional backslashes are the form the mistake actually takes. Writing
# open "{path}" inside a TOML basic string means typing \"{path}\", so the
# character next to the brace is a backslash and not the quote.
readonly PLACEHOLDER='(id|title|path|dir|query|(parent\.)+(id|title|path|dir))'
readonly QUOTED_PLACEHOLDER_RE="\\\\?[\"']\\{${PLACEHOLDER}\\}\\\\?[\"']"

# The exception, and the reason that check needs a second pass: a value that is
# nothing but a placeholder. There the quotes are TOML's own string delimiters
# rather than quotes somebody put around the substitution, so `do = ["{path}"]`
# over a directory of executables is correct and stays quiet.
#
# Two shapes, because a `do` list spreads over lines: the placeholder as the
# whole value (after `=`, with or without an opening bracket), and as a whole
# element of its own line. The second alternative anchors on grep's own
# "file:line:" prefix, which is where that line really starts here.
readonly WHOLE_VALUE_RE="(=[[:space:]]*\\[?|:[0-9]+:)[[:space:]]*[\"']\\{${PLACEHOLDER}\\}[\"'][[:space:]]*,?[[:space:]]*\\]?,?[[:space:]]*$"

# CONTRIBUTING: "Nothing downloads and runs code (curl ... | sh)."
# \b rather than whitespace-or-end: in a .toml the command ends at a quote.
readonly PIPE_TO_SHELL_RE='(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh|python[0-9.]*)\b'

failures=0

fail() {
    printf '  FAIL  %s\n' "$1"
    failures=$((failures + 1))
}

# One example, or all of them. The repo-wide checks (the template, every example
# installed together, the index table) run either way: they are invariants of
# the whole directory rather than of any one example, and they cost one parse
# between them.
only="${1:-}"
if [ -n "$only" ] && [ ! -d "$EXAMPLES_DIR/$only" ]; then
    echo "no $EXAMPLES_DIR/$only (make list)" >&2
    exit 1
fi

examples() {
    if [ -n "$only" ]; then
        printf '%s\n' "$EXAMPLES_DIR/$only/"
    else
        for dir in "$EXAMPLES_DIR"/*/; do printf '%s\n' "$dir"; done
    fi
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
while read -r dir; do
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

    # Tested rather than assumed: a parser that dies prints nothing, and an
    # unchecked output="$(...)" would take this whole run down under `set -e`
    # instead of recording one failed example and carrying on to the rest.
    if ! output="$("$parser" "$solo" 2>&1)"; then
        printf '%s\n' "$output" | sed 's/^/  /'
        fail "$name: the parser exited non-zero"
        continue
    fi

    if printf '%s\n' "$output" | grep -q '^problem:'; then
        printf '%s\n' "$output" | grep '^problem:' | sed 's/^/  /'
        fail "$name does not parse cleanly"
        continue
    fi

    # Kept for the README check further down, so the parser runs once per example.
    printf '%s\n' "$output" | awk '/^block /{print $2}' > "$WORK_DIR/ids-$name"

    block_count="$(grep -c . < "$WORK_DIR/ids-$name" || true)"
    if [ "$block_count" -eq 0 ]; then
        fail "$name declares no blocks (a file of nothing but comments parses perfectly and does nothing)"
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
    done < "$WORK_DIR/ids-$name"

    printf '  ok    %s file(s), %s block(s)\n' "${#tomls[@]}" "$block_count"
done < <(examples)

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

# 3. What the commands say.
#
# The parser judges the format; these are the house rules on top of it, and
# every one is a line from CONTRIBUTING's checklist. They are greps because they
# have to be: this script never runs a command, so reading what one says is the
# only thing available to it.
echo "commands"
read_count=0
while read -r dir; do
    tomls=("$dir"*.toml)
    [ -e "${tomls[0]}" ] || continue

    # Helper scripts get the same reading. A hard-coded home directory or a
    # curl-into-a-shell is no better for being one file further away.
    scripts=()
    for candidate in "$dir"bin/*; do
        [ -f "$candidate" ] && scripts+=("$candidate")
    done
    all_files=("${tomls[@]}" ${scripts+"${scripts[@]}"})

    while read -r hit; do
        [ -n "$hit" ] && fail "$hit  <- hard-coded home directory; write ~/ instead"
    done < <(grep -nHE "$HOME_DIR_RE" "${all_files[@]}" || true)

    # .toml only: a shell script quoting "$LOOK_PATH" is doing the right thing.
    #
    # Two greps rather than one pattern because ERE has no lookbehind, and what
    # separates the mistake from the exception is entirely what sits to the left.
    while read -r hit; do
        [ -n "$hit" ] && fail "$hit  <- placeholders are escaped for you; drop your quotes"
    done < <(grep -nHE "$QUOTED_PLACEHOLDER_RE" "${tomls[@]}" | grep -vE "$WHOLE_VALUE_RE" || true)

    while read -r hit; do
        [ -n "$hit" ] && fail "$hit  <- nothing here downloads and runs code"
    done < <(grep -nHE "$PIPE_TO_SHELL_RE" "${all_files[@]}" || true)

    read_count=$((read_count + 1))
done < <(examples)
printf '  ok    %s example(s) read\n' "$read_count"

echo

# 4. Paperwork every example owes its reader.
#
# Parsing proves the file is valid, never that the commands work. What is
# checkable from here is that the reader is told enough to judge for themselves:
# above all, which platforms the author actually ran it on.
echo "readmes"
documented=0
while read -r dir; do
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

    # What has to be installed. One line to write, and the difference between an
    # example that looks broken and one that just wants `jq`.
    grep -q '^\*\*Requires\.\*\*' "$readme" ||
        fail "$name: README needs a line starting \"**Requires.**\" naming what has to be installed"

    # The literal line somebody copies. new.sh gets this right; a folder renamed
    # by hand afterwards does not, and it fails in the worst way available,
    # which is silently installing a different example.
    grep -qF "cp examples/$name/*.toml" "$readme" ||
        fail "$name: README has no \"cp examples/$name/*.toml\" install line"

    # Every block the parser found should appear in the README's Blocks table. A
    # block nobody documents is a row the user cannot explain when it turns up.
    if [ -f "$WORK_DIR/ids-$name" ]; then
        while read -r id; do
            [ -n "$id" ] || continue
            grep -qF -- "\`$id\`" "$readme" ||
                fail "$name: block [$id] is not mentioned in README.md"
        done < "$WORK_DIR/ids-$name"
    fi

    # An example nobody can find is an example nobody runs.
    if ! grep -q "examples/$name" "$INDEX"; then
        fail "$name is missing from the index table in $INDEX"
    elif grep -qE "^\| \[$name\].*TODO" "$INDEX"; then
        fail "$name still has the TODO row new.sh wrote into $INDEX"
    fi

    for script in "$dir"bin/*; do
        [ -e "$script" ] || continue
        [ -x "$script" ] || fail "$script is not executable (chmod +x)"
        head -1 "$script" | grep -q '^#!' || fail "$script has no shebang"
    done

    documented=$((documented + 1))
done < <(examples)
printf '  ok    %s example(s) documented\n' "$documented"

echo

# 5. The repository itself.
#
# Always the whole tree, never the one example asked for: what these catch is
# weight and staleness, and both belong to the repo rather than to a folder.
echo "repository"

# CONTRIBUTING: "Link a GIF, do not commit it." Git keeps every version of a
# binary forever and cannot delta-compress one, so committing a 5 MB recording
# puts 5 MB into every clone from now on, and that cannot be taken back.
while read -r file; do
    if [ "$file" = "$GRANDFATHERED" ]; then
        printf '  note  %s predates the rule; re-host it and drop GRANDFATHERED\n' "$file"
        continue
    fi
    fail "$file: link media, do not commit it (CONTRIBUTING)"
done < <(find "$EXAMPLES_DIR" -type f ! -name '*.toml' ! -name '*.md' ! -path '*/bin/*' | sort)

# The same mistake made inside bin/, where a real script does belong.
while read -r file; do
    [ "$file" = "$GRANDFATHERED" ] && continue
    size="$(wc -c < "$file")"
    [ "$size" -le "$MAX_FILE_BYTES" ] ||
        fail "$file is $((size / 1024)) KB; nothing in here should be that big"
done < <(find "$EXAMPLES_DIR" -type f | sort)

# A row pointing at a folder somebody deleted.
while read -r name; do
    [ -n "$name" ] || continue
    [ -d "$EXAMPLES_DIR/$name" ] ||
        fail "$INDEX has an index row for \"$name\", which is not in $EXAMPLES_DIR/"
done < <(grep -oE "^\| \[[a-z0-9-]+\]" "$INDEX" | tr -d '|[] ' | sort -u)

printf '  ok    %s file(s), index table matches %s/\n' \
    "$(find "$EXAMPLES_DIR" -type f | wc -l | tr -d ' ')" "$EXAMPLES_DIR"

echo

if [ "$failures" -gt 0 ]; then
    printf '%s check(s) failed\n' "$failures"
    exit 1
fi
echo "all good"
