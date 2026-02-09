#!/bin/csh -fx 

#set years = ( 61 62 63 64 66 67 )
set years = ( 53 54 55 56 57 58 )
#set years = ( 58 )
set dollar = `echo '$'`
set i = 1
echo $dollar
#foreach filetag ( 0061020100-0063013100.nc.part1.nc.remap.nc 0061020100-0063013100.nc.part2.nc.remap.nc 0063020100-0065013100.nc.part1.nc.remap.nc 0063020100-0065013100.nc.part2.nc.remap.nc 0066020100-0068013100.nc.part1.nc.remap.nc 0066020100-0068013100.nc.part2.nc.remap.nc )
foreach filetag ( 0053011900-0055011800.nc.part1.nc.remap.nc 0053011900-0055011800.nc.part2.nc.remap.nc 0055011900-0057011800.nc.part1.nc.remap.nc 0055011900-0057011800.nc.part2.nc.remap.nc 0057011900-0059011800.nc.part1.nc.remap.nc 0057011900-0059011800.nc.part2.nc.remap.nc )
#0061020100-0063013100.nc.part1.nc.remap.nc 0061020100-0063013100.nc.part2.nc.remap.nc 0063020100-0065013100.nc.part1.nc.remap.nc 0063020100-0065013100.nc.part2.nc.remap.nc 0066020100-0068013100.nc.part1.nc.remap.nc 0066020100-0068013100.nc.part2.nc.remap.nc )

cat << EOF > covuq_$years[$i].ncl 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 dd= systemfunc("date -u +%y%m%d")
;;; 3 hourly input datasets mapped to the 0.23x0.31 resolution 
 fu = addfile("/glade/scratch/malbright/eddy_cov/plio_data/b.e13.B1850C5CN.ne120_g16.pliohiRes.002.cam.h3.U.${filetag}", "r")
 time  = cd_calendar(fu->time, 2)
 print(fu->time)
 fv = addfile("/glade/scratch/malbright/eddy_cov/plio_data/b.e13.B1850C5CN.ne120_g16.pliohiRes.002.cam.h3.V.${filetag}", "r")
 fq = addfile("/glade/scratch/malbright/eddy_cov/plio_data/b.e13.B1850C5CN.ne120_g16.pliohiRes.002.cam.h3.Q.${filetag}", "r")
 ; ncl8,427,533 ncl9,784,865 - box for the NAM region
ilatst = 427-10
ilated = 533+10
ilonst = 784-10
iloned = 865+10
 nlat = ilated - ilatst + 1
 nlon = iloned - ilonst + 1
;;;; 30 vertical levels - CAM hybrid coordinate
 covuq = new((/30, nlat, nlon/), "float")
 covvq = new((/30, nlat, nlon/), "float")
;;;; 29 vertical levels
 do i = 0, 29
;;;; finding indices for June 1st to July 31st for each year (e.g., 440601 to 440731)
    ist = $years[$i]*10000+601
    ied = $years[$i]*10000+731	
    print(ist)
    print(ied)
    indx = ind((time .ge. ist) .and. (time .le. ied))
    ntime = dimsizes(indx)

;;;; extract the data
    u = fu->U(indx,i, ilatst:ilated, ilonst:iloned)
    v = fv->V(indx,i, ilatst:ilated, ilonst:iloned) 
    q = fq->Q(indx,i, ilatst:ilated, ilonst:iloned) 
    
    opt     = True
    opt@nval_crit = 10 
    
    dt = 1./8. ; 1/8 days per time step
    t1 = 0.5  ;days
    t2 = 1.  ;10 days  (high frequency cutoff, expressed in time domain)

    fca = dt/t1
    fcb = dt/t2 

    nwt = 7  
    ihp = 1          ; high pass filter
    nsigma = 1.

;;;;;;;; lanczos filter to filter out frequencies lower than half a day: https://www.ncl.ucar.edu/Document/Functions/Built-in/filwgts_lanczos.shtml
    wts = filwgts_lanczos (nwt, ihp, fca, -999., nsigma)  

    ufil    = wgt_runave_n_Wrap(u, wts, 1, 0)
    vfil    = wgt_runave_n_Wrap(v, wts, 1, 0)
    qfil    = wgt_runave_n_Wrap(q, wts, 1, 0)
;;;;;;;; check the dimension - sanity check
	printVarSummary(ufil(lat|:, lon|:, time|:))
	print(ntime)
	ufil2d = onedtond(ndtooned(ufil(lat|:, lon|:, time|:)), (/nlat*nlon, ntime/))
	vfil2d = onedtond(ndtooned(vfil(lat|:, lon|:, time|:)), (/nlat*nlon, ntime/))
	qfil2d = onedtond(ndtooned(qfil(lat|:, lon|:, time|:)), (/nlat*nlon, ntime/))
;;;;;;;; calculate co-variance of filtered U and Q, and V and Q
	covx_uq = dim_sum_Wrap( \
		(ufil2d - conform(ufil2d, dim_avg_Wrap(ufil2d), (/0/)))*\
		(qfil2d - conform(qfil2d, dim_avg_Wrap(qfil2d), (/0/))))/(ntime - 1)
	covx_vq = dim_sum_Wrap( \
		(vfil2d - conform(vfil2d, dim_avg_Wrap(vfil2d), (/0/)))*\
		(qfil2d - conform(qfil2d, dim_avg_Wrap(qfil2d), (/0/))))/(ntime - 1)
;;;;;;;; create an empty array to start and then add up the co-variance for each year
    	covuq(i,:,:) = onedtond(covx_uq, (/nlat, nlon/))
    	covvq(i,:,:) = onedtond(covx_vq, (/nlat, nlon/))
  end do
;;;;;;;;; copy the dimensional information
	copy_VarCoords(u(0,:,:), covuq(0,:,:))
	copy_VarCoords(v(0,:,:), covvq(0,:,:))
;;;;;;;; write out the calculated co-variance
  system("rm covVQ2_"+$years[$i]+".nc")
  f = addfile("/glade/scratch/malbright/eddy_cov/covVQ2_"+$years[$i]+".nc", "c")
  f->covuq = covuq
  f->covvq = covvq
end
EOF
cat << EOF > sub_covuq_$years[$i].csh 
#! /bin/csh -fx 
#PBS -A UCNN0024
#PBS -N covuq
#PBS -q regular
#PBS -l select=1:ncpus=36:mpiprocs=36:ompthreads=1
#PBS -l walltime=12:00:00
#PBS -j oe
#PBS -m ae
#PBS -S /bin/csh -V

### Run program
ncl ./covuq_$years[$i].ncl
EOF
qsub -V sub_covuq_$years[$i].csh
@ i = $i + 1
end
