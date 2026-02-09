#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "${HERE}/config.sh"

for VAR in ${VARS_ALL}; do
  in_root="${JJ_DIR}/${VAR}"
  [[ -d "${in_root}" ]] || continue
  find "${in_root}" -maxdepth 1 -type f -name "*.JJ.nc" | sort | while read -r f; do
    base="$(basename "${f%*.JJ.nc}")"
    out="${H03_DIR}/${VAR}/${base}.JJ.h03.nc"
    mkdir -p "$(dirname "$out")"
    log="${LOG_DIR}/H03_${VAR}_${base}.log"
    qsub -N "H03_${VAR}" \
         -v VAR="${VAR}",IN_FILE="${f}",OUT_FILE="${out}" \
         -o "${log}" "${HERE}/pbs_selhour3.sh"
    echo "Submitted h03 ${VAR}: ${base}"
  done
done

