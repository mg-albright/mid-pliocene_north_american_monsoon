#!/bin/bash

##=======================================================================
#PBS -N tempest.par
#PBS -A UCNN0024
#PBS -l walltime=12:00:00
#PBS -q regular
#PBS -j oe
#PBS -l select=2:ncpus=36:mpiprocs=36
################################################################

# set tempestextremes directory
TEMPESTEXTREMESDIR=/glade/u/home/malbright/tempestextremes/

VAR="PRECT" # Var to be tracked
#THRESHOLD=2.8e-6  # threshold for cell to be considered (in m/s ~10 mm/hr)
THRESHOLD=0.45e-6  # threshold for cell to be considered ( abt 2.5 mm/hr)
RADIUS=0.7  # degrees smoothing near radius of cells
MINSIZE=6  # required gridboxes contiguous, currently about the size of delaware
MINTIME=2   # number of consecutive timesteps to be considered a blob
MINOVERLAP=20  # percent area overlap required between successive timesteps (for hourly data, this can be > 0, not sure about 3 or 6-hourly...
MAXOVERLAP=60  # percent area overlap required between successive timesteps (for hourly data, this can be > 0, not sure about 3 or 6-hourly...

# get unique date string for temp filelist file
DATESTRING=`date +"%s%N"`
FILELISTNAME=filelist.txt.${DATESTRING}
touch $FILELISTNAME

# Generate parallel file
#for f in /glade/u/home/malbright/work/storm_tracking/test_data/b.e13.B1850C5CN.ne120_g16.tuning.005.cam.h3.PRECT.007*.remap.nc;
for f in /glade/scratch/malbright/hourly1/plio_1/b.e13.B1850C5CN.ne120_g16.pliohiRes.002.cam.h5.PRECT.*.remap.nc.part*.nc;
do
  echo "${f}" >> $FILELISTNAME
done

# First, find candidate blobs at each timestep, store in tmp mask files and concatenate

#${TEMPESTEXTREMESDIR}/bin/SpineARs_v2 --in_data_list $FILELISTNAME --out mask.tmp --regional --thresholdcmd "${VAR},>=,${THRESHOLD},${RADIUS}" --verbosity 3

mpiexec ${TEMPESTEXTREMESDIR}/bin/DetectBlobs --in_data_list $FILELISTNAME --out mask.tmp --regional --diag_connect --thresholdcmd "${VAR},>=,${THRESHOLD},${RADIUS}" --verbosity 3 </dev/null
ncrcat -O mask.tmp* mask1.nc
rm mask.tmp*

# Then stitch blobs and filter by min requirements to be considered a trackable entity
${TEMPESTEXTREMESDIR}/bin/StitchBlobs --in mask1.nc --out blobs1.nc --var binary_tag --outvar MCS_${VAR} --regional --minsize ${MINSIZE} --mintime ${MINTIME} --min_overlap_next ${MINOVERLAP} --max_overlap_next ${MAXOVERLAP}

# remove parallel file
#rm core*
rm $FILELISTNAME
rm log0*txt
