#!/usr/bin/env bash
#PBS -N H03
#PBS -A UCNN0041
#PBS -q casper
#PBS -l select=1:ncpus=2:mem=10GB
#PBS -l walltime=01:30:00
#PBS -j oe

set -euo pipefail

CONFIG="${CONFIG:-/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/scripts/config.sh}"
if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config.sh not found at $CONFIG" >&2
  exit 1
fi
source "$CONFIG"

module load cdo >/dev/null 2>&1 || true

echo "[H03] START $(date) host=$(hostname)"
echo "[H03] VAR=${VAR}"
echo "[H03] IN = ${IN_FILE}"
echo "[H03] OUT= ${OUT_FILE}"
echo "[H03] CDO_P=${CDO_P}"

mkdir -p "$(dirname "${OUT_FILE}")"
cdo -O -L -b F64 ${CDO_P} selhour,3 "${IN_FILE}" "${OUT_FILE}"

echo "[H03] DONE $(date)"

