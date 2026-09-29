#!/usr/bin/env bash
#
# Remove files in a directory that are NOT symlinks. The target directory
# is given as an argument and defaults to the current directory.
# Symlinks are preserved. The script never removes itself, even when
# run from the directory it lives in. By default this is non-recursive
# and only affects regular files (directories are left alone unless -d).

set -euo pipefail

recursive=false
dry_run=false
include_dirs=false

usage() {
    cat <<'EOF'
Usage: remove-non-symlinks.sh [-r] [-d] [-n] [-h] [DIR]

Removes entries in DIR that are not symlinks. DIR defaults to the
current directory. The script itself is always preserved.

Options:
  -n  Dry run: print what would be removed, but don't remove anything.
  -r  Recurse into subdirectories.
  -d  Also remove non-symlink directories (implies recursion into them).
  -h  Show this help.

Symlinks are always preserved (and not followed).
EOF
}

while getopts ":rdnh" opt; do
    case "$opt" in
        r) recursive=true ;;
        d) include_dirs=true ;;
        n) dry_run=true ;;
        h) usage; exit 0 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

# Target directory: first positional arg, default to current directory.
target_dir="${1:-.}"
if [ $# -gt 1 ]; then
    echo "Error: only one directory may be given (got $#)." >&2
    usage >&2
    exit 2
fi
if [ ! -d "$target_dir" ]; then
    echo "Error: not a directory: $target_dir" >&2
    exit 2
fi

# Resolve this script's own absolute path so we never delete it.
# Use $0; fall back to BASH_SOURCE. Resolve symlinks where possible.
self_raw="${BASH_SOURCE[0]:-$0}"
if command -v realpath >/dev/null 2>&1; then
    self_path="$(realpath -- "$self_raw" 2>/dev/null || true)"
else
    # Portable fallback: resolve the directory, keep the basename.
    self_dir="$(cd "$(dirname -- "$self_raw")" >/dev/null 2>&1 && pwd -P)"
    self_path="$self_dir/$(basename -- "$self_raw")"
fi

# Build the find command. Recurse when -r or -d is given, otherwise
# stay at the top level.
find_args=("$target_dir" -mindepth 1)
if [ "$recursive" = false ] && [ "$include_dirs" = false ]; then
    find_args+=(-maxdepth 1)
fi

# Select non-symlink files (and optionally directories). -depth ensures
# a directory's contents are listed before the directory itself.
if [ "$include_dirs" = true ]; then
    find_args+=(-depth ! -type l)
else
    find_args+=(-type f)
fi

# Returns 0 if the entry is this script itself.
is_self() {
    local entry="$1" resolved
    if command -v realpath >/dev/null 2>&1; then
        resolved="$(realpath -- "$entry" 2>/dev/null || true)"
    else
        local d
        d="$(cd "$(dirname -- "$entry")" >/dev/null 2>&1 && pwd -P)" || return 1
        resolved="$d/$(basename -- "$entry")"
    fi
    [ -n "$self_path" ] && [ "$resolved" = "$self_path" ]
}

remove() {
    local target="$1"
    if is_self "$target"; then
        printf 'skipping self: %s\n' "$target"
        return
    fi
    if [ "$dry_run" = true ]; then
        printf 'would remove: %s\n' "$target"
    else
        rm -rf -- "$target"
        printf 'removed: %s\n' "$target"
    fi
}

# Null-delimited to handle names with spaces or newlines safely.
while IFS= read -r -d '' entry; do
    remove "$entry"
done < <(find "${find_args[@]}" -print0)
