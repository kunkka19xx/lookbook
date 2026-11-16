#!/usr/bin/env bash
#
# Scans what this repo hands to other people's machines, for the mistakes a
# scanner can actually find. `make check` asks whether Look can read a file;
# this asks whether the code around it is careless.
#
#   ./scripts/security.sh
#
# One tool per kind of file that executes. (Each name is in backticks because a
# comment that starts with the bare word is a directive to the first of them.)
#
#   `shellcheck`  every shell script: the bin/ helpers and scripts/ itself.
#                 Everything but style notes. The ones that matter here are
#                 about quoting, because row data is text somebody else chose: a
#                 branch, a container or a file name with a space or a `*` in
#                 it becomes several arguments, or a list of files, wherever it
#                 is expanded unquoted.
#   `bandit`      every Python script, medium severity and up. The low ones say
#                 "this file uses subprocess", which every helper here does on
#                 purpose, to reach pbcopy or xdg-open.
#   `zizmor`      the GitHub workflows and dependabot.yml: actions not pinned
#                 to a commit, tokens with more permission than the job needs,
#                 PR text expanded into a shell. With GH_TOKEN set it also looks
#                 the pinned actions up against published advisories.
#
# What none of them read is the commands in the .toml files, which are most of
# this repo. Those are shell text Look runs, and the rules for them (no
# `curl | sh`, no quoted placeholder) live in check.sh, next to the parser that
# reads them. The rest is review: no scanner can tell a source that opens your
# notes from one that uploads them.
#
# The scanners are installed into .security-tools/ (gitignored) from the
# versions pinned in scripts/security/requirements.txt, on the first run and
# again whenever that list changes. So CI and every laptop run the same
# versions and find the same things, and nothing is installed anywhere else.
# Needs python3.
#
# Written for bash 3.2, which is still what macOS runs as `bash`: no mapfile,
# and no expanding an empty array under `set -u`.
set -euo pipefail

cd "$(dirname "$0")/.."

readonly TOOLS_DIR=".security-tools"
readonly REQUIREMENTS="scripts/security/requirements.txt"


# ---------------------------------------------------------------- scanners --

# Rebuilt when the pinned list changes, not only when the folder is missing:
# otherwise a version bump that CI picks up would leave a laptop quietly
# scanning with the old one.
ensure_tools() {
    if cmp -s "$REQUIREMENTS" "$TOOLS_DIR/installed.txt"; then
        return
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        echo "security.sh: needs python3 to install its scanners" >&2
        exit 1
    fi
    echo "installing the scanners pinned in $REQUIREMENTS into $TOOLS_DIR/" >&2
    rm -rf "$TOOLS_DIR"
    python3 -m venv "$TOOLS_DIR"
    "$TOOLS_DIR/bin/pip" install --quiet --disable-pip-version-check -r "$REQUIREMENTS"
    cp "$REQUIREMENTS" "$TOOLS_DIR/installed.txt"
}


# ------------------------------------------------------------------- files --

# Tracked files plus new ones not added yet, so a script you are still writing
# is scanned before it is committed. Ignored paths (.look-src, the scanners
# themselves) are skipped by the same rules git uses.
candidates() {
    git ls-files --cached --others --exclude-standard
}

# By extension, or by shebang for the bin/ scripts, which mostly have none.
# `if` rather than `&&`, so a file that is not a match is not a failure.
scripts_matching() {
    local extension="$1" shebang="$2" file
    candidates | while IFS= read -r file; do
        [ -f "$file" ] || continue
        case "$file" in
            *."$extension") printf '%s\n' "$file" ;;
            *.*) ;;
            *)
                if head -n 1 "$file" | grep -qE "$shebang"; then
                    printf '%s\n' "$file"
                fi
                ;;
        esac
    done
}

shell_scripts()  { scripts_matching sh '^#!.*[/ ](ba|da|k)?sh([[:space:]]|$)'; }
python_scripts() { scripts_matching py '^#!.*[/ ]python[0-9.]*([[:space:]]|$)'; }


# --------------------------------------------------------------------- run --

failed=""

# Runs one scanner and remembers whether it passed, so every scanner gets to
# report before the script exits: fixing one thing at a time is slower.
scan() {
    local name="$1"
    shift
    printf '\n== %s\n' "$name"
    if "$@"; then
        printf 'clean\n'
    else
        failed="$failed $name"
    fi
}

ensure_tools

shell=()
while IFS= read -r file; do shell+=("$file"); done < <(shell_scripts)
python=()
while IFS= read -r file; do python+=("$file"); done < <(python_scripts)

if [ "${#shell[@]}" -gt 0 ]; then
    # `info` and not `warning`, because an unquoted "$name" (SC2086) is an
    # info note to shellcheck and the reason it is here. SC2016 is left out:
    # it flags '$var' in single quotes, which in this repo is a jq or awk
    # program reading its own variables, on purpose, every time.
    scan "shellcheck (${#shell[@]} scripts)" \
        "$TOOLS_DIR/bin/shellcheck" --severity=info --exclude=SC2016 "${shell[@]}"
fi

if [ "${#python[@]}" -gt 0 ]; then
    scan "bandit (${#python[@]} scripts)" \
        "$TOOLS_DIR/bin/bandit" --quiet --severity-level medium "${python[@]}"
fi

# Online, the advisory lookups need a token; without one they are skipped
# rather than failing, and the run says so.
zizmor_args=()
if [ -z "${GH_TOKEN:-}" ]; then
    zizmor_args+=(--offline)
    echo "(no GH_TOKEN, so zizmor runs offline: GH_TOKEN=\$(gh auth token) make security checks advisories too)" >&2
fi
scan "zizmor (workflows)" \
    "$TOOLS_DIR/bin/zizmor" "${zizmor_args[@]+"${zizmor_args[@]}"}" .github/

if [ -n "$failed" ]; then
    printf '\nfailed:%s\n' "$failed"
    exit 1
fi
printf '\nall clean\n'
