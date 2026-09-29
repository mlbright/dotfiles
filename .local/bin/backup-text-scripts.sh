#!/usr/bin/env bash
#
# Copy human-readable (text) files from a source directory, default
# ~/.local/bin, into the current directory. Binary executables are
# skipped, so this can be used to keep scripts under version control
# without dragging in compiled tools. Non-recursive; directories are
# ignored. Symlinks are followed and copied as regular files when their
# target is text.

set -euo pipefail

src="$HOME/.local/bin"
dry_run=false

usage() {
    cat <<'EOF'
Usage: backup-text-scripts.sh [-n] [-h] [SRC_DIR]

Copies text files from SRC_DIR (default: ~/.local/bin) into the current
directory. Binary files are skipped.

Options:
  -n  Dry run: print what would be copied, but don't copy anything.
  -h  Show this help.
EOF
}

while getopts ":nh" opt; do
    case "$opt" in
        n) dry_run=true ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
fi
[[ $# -eq 1 ]] && src="$1"

if [[ ! -d "$src" ]]; then
    echo "error: '$src' is not a directory" >&2
    exit 1
fi

dest="$(pwd -P)"
if [[ "$(cd "$src" && pwd -P)" == "$dest" ]]; then
    echo "error: source and destination are the same directory" >&2
    exit 1
fi

copied=0
skipped=0

for path in "$src"/* "$src"/.[!.]*; do
    [[ -e "$path" ]] || continue   # unmatched glob or dangling symlink
    [[ -f "$path" ]] || continue   # regular files (or symlinks to them) only
    name="$(basename "$path")"

    # `file` reports "binary" for non-text content; empty files report
    # "binary" too on some systems, so treat them as text explicitly.
    encoding="$(file -bL --mime-encoding "$path")"
    if [[ "$encoding" == "binary" && -s "$path" ]]; then
        echo "skip (binary): $name"
        skipped=$((skipped + 1))
        continue
    fi

    if $dry_run; then
        echo "would copy: $name"
    else
        cp -pL "$path" "$dest/$name"
        echo "copied: $name"
    fi
    copied=$((copied + 1))
done

echo "$copied text file(s) $($dry_run && echo "to copy" || echo "copied"), $skipped binary file(s) skipped"
