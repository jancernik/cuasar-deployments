#!/usr/bin/env bash

# Sync Homepage's local icons with the dashboard-icons repo.
# Download every /icons/<name> referenced in the config,
# keep custom icons, and remove unused ones.
# Pass -n for a dry run.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$script_dir/config"
ICONS_DIR="$script_dir/icons"
REPO="https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main"

dry_run=0
[[ "${1:-}" == "-n" ]] && dry_run=1

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

mapfile -t refs < <(
	grep -rhoE '/icons/[A-Za-z0-9._-]+' --include='*.yaml' --exclude-dir=logs "$CONFIG_DIR" |
		sed 's#/icons/##' | sort -u
)

for ref in "${refs[@]}"; do
	ext="${ref##*.}"
	if curl -fsS "$REPO/$ext/$ref" -o "$tmp" 2>/dev/null; then
		((dry_run)) || cp "$tmp" "$ICONS_DIR/$ref"
		echo "download  $ref"
	elif [[ -f "$ICONS_DIR/$ref" ]]; then
		echo "custom    $ref"
	else
		echo "MISSING   $ref"
	fi
done

refs_list="$(printf '%s\n' "${refs[@]}")"
for f in "$ICONS_DIR"/*; do
	name="$(basename "$f")"
	grep -qxF "$name" <<<"$refs_list" && continue
	((dry_run)) || rm -f "$f"
	echo "remove    $name"
done
  