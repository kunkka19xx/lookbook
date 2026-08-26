#!/usr/bin/env bash
# Scaffolds a new example from template/, with every "template" already renamed.
#
#   make new NAME=tmux
#
# What is left to do afterwards is the part only you can write: the commands,
# and the sentences describing them.
set -euo pipefail

readonly TEMPLATE_DIR="template"
readonly EXAMPLES_DIR="examples"
readonly INDEX="README.md"

name="${1:-}"

if [ -z "$name" ]; then
    echo "usage: make new NAME=tmux" >&2
    exit 1
fi

# The name becomes a folder, a file name, and a prefix on every block id, so it
# has to be usable as all three. A block id may not contain ":" at all, and
# anything with a space in it makes for miserable shell text.
if ! printf '%s' "$name" | grep -Eq '^[a-z][a-z0-9-]*$'; then
    echo "\"$name\" must be lowercase letters, digits and dashes, starting with a letter" >&2
    exit 1
fi

dir="$EXAMPLES_DIR/$name"
if [ -e "$dir" ]; then
    echo "$dir already exists" >&2
    exit 1
fi

mkdir -p "$dir"

# "Template" is the display name a user reads; "template" is the id, the file
# name and the folder. Both are renamed, so the only strings left to edit are
# the ones describing what your example actually does.
display="$(printf '%s' "$name" | tr '-' ' ')"
display="$(printf '%s' "${display%"${display#?}"}" | tr '[:lower:]' '[:upper:]')${display#?}"

rename() {
    sed -e "s/template/$name/g" -e "s/Template/$display/g" "$1"
}

rename "$TEMPLATE_DIR/template.toml" > "$dir/$name.toml"
rename "$TEMPLATE_DIR/README.md" > "$dir/README.md"

# NOTES.md is the instructions for copying the template, not part of an example.

# The index row, which check.sh requires. Added here so a new example is
# findable from the moment it exists, rather than at the end when it is easy to
# forget. Inserted after the last row of the table.
awk -v row="| [$name]($EXAMPLES_DIR/$name) | TODO | TODO | TODO |" '
    { lines[NR] = $0; if ($0 ~ /^\| \[/) last = NR }
    END {
        for (i = 1; i <= NR; i++) {
            print lines[i]
            if (i == last) print row
        }
        if (last == 0) print row
    }
' "$INDEX" > "$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"

cat <<DONE
Created $dir

  $dir/$name.toml
  $dir/README.md

Next:
  1. Edit $dir/$name.toml. One producer key per block: do, dir, file, or run.
  2. Edit $dir/README.md. Say what you get, what it requires, and which
     platforms you actually tested on.
  3. Fill in the TODO row for $name in $INDEX.
  4. make install NAME=$name, reload Look, and use it for real.
  5. make check
DONE
