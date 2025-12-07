#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <chess_com_username>" >&2
    exit 1
fi

USERNAME="$1"
OUT_DIR="${USERNAME}"

# Require jq (just for extracting the list of monthly archive URLs)
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed. Install it and try again." >&2
    exit 1
fi

BASE_URL="https://api.chess.com/pub/player/${USERNAME}/games/archives"

echo "Fetching archive list for user: ${USERNAME}" >&2

# -k to bypass Windows/Cygwin SSL chain issues
ARCHIVES_JSON="$(curl -kfsSL "$BASE_URL")" || {
    echo "Error: failed to fetch archives for user ${USERNAME}." >&2
    exit 1
}

mkdir -p "$OUT_DIR"

echo "Processing archives..." >&2

# Loop through monthly archive links
echo "$ARCHIVES_JSON" | jq -r '.archives[]' | while IFS= read -r url; do
    # Extract YYYYMM
    ym="$(echo "$url" | sed -E 's#.*/([0-9]{4})/([0-9]{2}).*#\1\2#')"
    out_file="${OUT_DIR}/${USERNAME}_${ym}.json"

    echo "  → Fetching JSON for ${ym} → ${out_file}" >&2

    if curl -kfsSL "$url" -o "$out_file"; then
        :
    else
        echo "    Warning: failed to fetch JSON from ${url}" >&2
    fi
done

echo "Done. Raw monthly JSON files are in: ${OUT_DIR}" >&2
