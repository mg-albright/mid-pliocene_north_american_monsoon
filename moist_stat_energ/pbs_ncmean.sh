#!/usr/bin/env bash
#PBS -N MEAN
#PBS -A UCNN0041
#PBS -q casper
#PBS -l select=1:ncpus=2:mem=20GB
#PBS -l walltime=01:00:00
#PBS -j oe

set -euo pipefail

CONFIG="${CONFIG:-/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/scripts/config.sh}"
if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config.sh not found at $CONFIG" >&2
  exit 1
fi
source "$CONFIG"

module load nco >/dev/null 2>&1 || true

echo "[MEAN] START $(date) host=$(hostname)"
echo "[MEAN] VAR=${VAR}"
echo "[MEAN] IN_DIR=${IN_DIR}"
echo "[MEAN] OUT=${OUT_FILE}"

mkdir -p "$(dirname "${OUT_FILE}")"

mapfile -t files < <(find "${IN_DIR}" -maxdepth 1 -type f -name "*.JJ.h03.nc" | sort)
echo "[MEAN] Found ${#files[@]} inputs"
if (( ${#files[@]} == 0 )); then
  echo "[MEAN] No input files found for ${VAR}" >&2
  exit 2
fi

ncra -O "${files[@]}" "${OUT_FILE}"

echo "[MEAN] DONE $(date)"

