#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "${HERE}/config.sh"

# Submit per-file JJ jobs for Z3/Q/T (h3) and PS (h4)
for VAR in ${VARS_H3}; do
  find "${H3_DIR}" -maxdepth 1 -type f -name "*cam.h3.${VAR}.*.nc" | sort | while read -r f; do
    base="$(basename "${f%*.nc}")"
    out="${JJ_DIR}/${VAR}/${base}.JJ.nc"
    mkdir -p "$(dirname "$out")"
    log="${LOG_DIR}/JJ_${VAR}_${base}.log"
    qsub -N "JJ_${VAR}" \
    	 -v VAR="${VAR}",IN_FILE="${f}",OUT_FILE="${out}" \
         -o "${log}" "${HERE}/pbs_selmon_jj.sh"
    echo "Submitted JJ ${VAR}: ${base}"
  done
done

# PS (h4)
VAR="PS"
find "${H4_DIR}" -maxdepth 1 -type f -name "*cam.h4.${VAR}.*.nc" | sort | while read -r f; do
  base="$(basename "${f%*.nc}")"
  out="${JJ_DIR}/${VAR}/${base}.JJ.nc"
  mkdir -p "$(dirname "$out")"
  log="${LOG_DIR}/JJ_${VAR}_${base}.log"
  qsub -N "JJ_${VAR}" \
       -v VAR="${VAR}",IN_FILE="${f}",OUT_FILE="${out}" \
       -o "${log}" "${HERE}/pbs_selmon_jj.sh"
  echo "Submitted JJ ${VAR}: ${base}"
done

