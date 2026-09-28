#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
curl -fsSL https://raw.githubusercontent.com/AmrAzirar/dddm-uplift-marketing/a1491f29e214a2db41d6380733d8f91da9ed410e/data/hillstrom.csv -o data/hillstrom.csv
echo "27bab8c5d3669f26ec08ebb50a0a78317542f29501156f2e2af6781fab4cd7e2  data/hillstrom.csv" | sha256sum -c -
