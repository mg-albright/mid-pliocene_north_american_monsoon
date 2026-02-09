#!/usr/bin/env bash
#PBS -N JJ
#PBS -A UCNN0041
#PBS -q casper 
#PBS -l select=1:ncpus=2:mem=20GB
#PBS -l walltime=01:30:00
#PBS -j oe

set -euo pipefail

# --- Source config by absolute path (allow override via $CONFIG) ---
CONFIG="${CONFIG:-/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/scripts/config.sh}"
if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config.sh not found at $CONFIG" >&2
  exit 1
fi
source "$CONFIG"

module load cdo >/dev/null 2>&1 || true

echo "[JJ] START $(date) host=$(hostname)"
echo "[JJ] VAR=${VAR}"
echo "[JJ] IN = ${IN_FILE}"
echo "[JJ] OUT= ${OUT_FILE}"
echo "[JJ] YEARS=${YEARS}  CDO_P=${CDO_P}"

mkdir -p "$(dirname "${OUT_FILE}")"

# Filter to years 0035–0059 and months June/July
#cdo -O -L -b F64 ${CDO_P} -selyear,${YEARS} -selmon,6,7 "${IN_FILE}" "${OUT_FILE}"
cdo selyear,${YEARS} -selmon,6,7 "${IN_FILE}" "${OUT_FILE}"

echo "[JJ] DONE $(date)"

