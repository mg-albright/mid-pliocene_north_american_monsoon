#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "${HERE}/config.sh"

for VAR in ${VARS_ALL}; do
  in_dir="${H03_DIR}/${VAR}"
  out_file="${MEAN_DIR}/${VAR}_JJ_h03_mean.nc"
  log="${LOG_DIR}/MEAN_${VAR}.log"
  qsub -N "MEAN_${VAR}" \
       -v VAR="${VAR}",IN_DIR="${in_dir}",OUT_FILE="${out_file}" \
       -o "${log}" "${HERE}/pbs_ncmean.sh"
  echo "Submitted MEAN ${VAR}"
done

