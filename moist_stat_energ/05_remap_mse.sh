#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "${HERE}/config.sh"
module load nco >/dev/null 2>&1 || true

in_native="${FINAL_NATIVE}/mse_plio_hr_ne120_JJ_h03_mean_interp.nc"
out_remap="${FINAL_REMAP}/mse_plio_hr_ne120_JJ_h03_mean_interp.remap.nc"

mkdir -p "$(dirname "${out_remap}")"

echo "[REMAP] START $(date) host=$(hostname)"
echo "[REMAP] IN  = ${in_native}"
echo "[REMAP] OUT = ${out_remap}"
echo "[REMAP] WGT = ${WGT_NE120}"

ncremap -m "${WGT_NE120}" "${in_native}" "${out_remap}"

echo "[REMAP] DONE $(date)"

