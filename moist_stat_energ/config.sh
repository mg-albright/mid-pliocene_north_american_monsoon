#!/usr/bin/env bash
# Common paths & settings (source this in the submit scripts)
set -euo pipefail

export ACCNT="UCNN0041"
export QUEUE="casper"

# Input root
export ROOT_IN="/glade/campaign/cesm/development/palwg/pliocene/SVF/b.e13.B1850C5CN.ne120_g16.pliohiRes.002/atm/proc/tseries"

# Working/output roots (as you requested)
export ROOT_OUT="/glade/derecho/scratch/malbright/moist_stat_energ"
export JJ_DIR="${ROOT_OUT}/JJ"
export H03_DIR="${ROOT_OUT}/h03"
export MEAN_DIR="${ROOT_OUT}/means"
export FINAL_NATIVE="/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/final/native"
export FINAL_REMAP="/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/final/remapped"

# Logs
export LOG_DIR="${ROOT_OUT}/logs"
mkdir -p "${JJ_DIR}" "${H03_DIR}" "${MEAN_DIR}" "${FINAL_NATIVE}" "${FINAL_REMAP}" "${LOG_DIR}"

# Variables & locations
export VARS_H3="Z3 Q T"
export VARS_ALL="Z3 Q T PS"
export H3_DIR="${ROOT_IN}/hour_3"
export H4_DIR="${ROOT_IN}/hour_1"

# Years & CDO threading
export YEARS="35/59"
export CDO_P="-P 2"

# Weight file for remap
export WGT_NE120="/glade/u/home/malbright/nam_manuscript_figures/climatology_files/map_ne120np4_TO_f02_blin.220120.nc"

