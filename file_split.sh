#!/bin/bash

# split_files.sh - split/rejoin large files in a directory
# Usage:
#   ./split_files.sh split|join <directory> [--delete]

set -e

SIZE_LIMIT=$((100*1024*1024))
CMD=$1
DIR=$2
DELETE=$([ "$3" == "--delete" ] && echo true || echo false)

[ -d "$DIR" ] || { echo "Directory $DIR does not exist!"; exit 1; }
cd "$DIR"

case "$CMD" in
  split)
    for f in *; do
      [ -f "$f" ] || continue
      [ $(stat -c%s "$f") -gt $SIZE_LIMIT ] || continue
      echo "Splitting $f..."
      split -b $SIZE_LIMIT -d --additional-suffix=.SPLIT "$f" "$f-SPLIT-"
      $DELETE && rm -f "$f"
    done
    echo "Split complete."
    ;;
  join)
    for base in $(ls *-SPLIT-* 2>/dev/null | sed 's/-SPLIT-[0-9][0-9][0-9]$//' | sort -u); do
      parts=$(ls "$base"-SPLIT-* 2>/dev/null | sort)
      [ -z "$parts" ] && continue
      echo "Joining $base..."
      cat $parts > "$base"
      $DELETE && rm -f $parts
    done
    echo "Join complete."
    ;;
  *)
    echo "Unknown command: $CMD"; exit 1
    ;;
esac
