#!/usr/bin/env bash
# Scaffolds a new example from template/, with every "template" already renamed.
#
#   make new NAME=tmux            a source, in sources/
#   make new-tile NAME=disk       a Super Actions tile, in tiles/
#
# What is left to do afterwards is the part only you can write: the commands,
# and the sentences describing them.
set -euo pipefail

readonly TEMPLATE_DIR="template"
readonly INDEX="README.md"

# The two kinds differ in one thing that matters here: where they end up, and
# therefore which table in the index they belong to. Everything after that is
# the same renaming.
kind="${1:-source}"
name="${2:-}"

case "$kind" in
    source)
        dir_root="sources"
        template_toml="$TEMPLATE_DIR/source.toml"
        template_readme="$TEMPLATE_DIR/source-README.md"
        marker="index:sources"
        columns="| TODO | TODO | TODO |"
        ;;
    tile)
        dir_root="tiles"
        template_toml="$TEMPLATE_DIR/tile.toml"
        template_readme="$TEMPLATE_DIR/tile-README.md"
        marker="index:tiles"
        columns="| TODO | TODO | TODO |"
        ;;
    *)
        echo "unknown kind \"$kind\" (source or tile)" >&2
        exit 1
        ;;
esac

if [ -z "$name" ]; then
    echo "usage: make new NAME=tmux   /   make new-tile NAME=disk" >&2
    exit 1
fi

# The name becomes a folder, a file name, and a prefix on every block or tile
# id, so it has to be usable as all three. A block id may not contain ":" at
# all, and anything with a space in it makes for miserable shell text. A tile
# name has it worse still: it is a token in a whitespace-separated drawing.
if ! printf '%s' "$name" | grep -Eq '^[a-z][a-z0-9-]*$'; then
    echo "\"$name\" must be lowercase letters, digits and dashes, starting with a letter" >&2
    exit 1
fi

dir="$dir_root/$name"
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

rename "$template_toml" > "$dir/$name.toml"
rename "$template_readme" > "$dir/README.md"

# NOTES.md is the instructions for copying the template, not part of an example.

# The index row, which check.sh requires. Added here so a new example is
# findable from the moment it exists, rather than at the end when it is easy to
# forget.
#
# Inserted before the marker that closes its own table, rather than after the
# last row in the file: there are two tables now, and "the last row" is only
# ever the second one's.
awk -v row="| [$name]($dir) $columns" -v marker="<!-- /$marker -->" '
    $0 ~ marker && !done { print row; done = 1 }
    { print }
' "$INDEX" > "$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"

if ! grep -qF "($dir)" "$INDEX"; then
    echo "warning: could not find the <!-- /$marker --> line in $INDEX; add the row by hand" >&2
fi

if [ "$kind" = tile ]; then
    cat <<DONE
Created $dir

  $dir/$name.toml
  $dir/README.md

Next:
  1. Edit $dir/$name.toml. At least one of value and press. A value command
     has two seconds and 16 KB, and runs unattended.
  2. Edit $dir/README.md. Say what it shows, what it requires, and which
     platforms you actually tested on.
  3. Fill in the TODO row for $name in $INDEX.
  4. make show NAME=$name, merge it into ~/.look/super-actions.toml, reload,
     and look at it for a while.
  5. make check
DONE
else
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
fi
