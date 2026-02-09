#!/usr/bin/env python3
"""
Compute JJ 03Z-mean Moist Static Energy (kJ/kg) at fixed pressure levels
for Plio high-res (ne120) using mean fields from Step 3, then save the
native-grid output to:
  /glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/final/native/
with filename:
  mse_plio_hr_ne120_JJ_h03_mean_interp.nc
"""

import os
import glob
import numpy as np
import xarray as xr

# GeoCAT
from geocat.comp import interp_hybrid_to_pressure

ROOT = "/glade/derecho/scratch/malbright/moist_stat_energ"
MEAN_DIR = f"{ROOT}/means"
FINAL_NATIVE = "/glade/u/home/malbright/nam_manuscript_figures/moist_stat_energ/final/native"

# Constants
Lv = 2500840.0  # J/kg
Cp = 1005.0     # J/(kg*K)
g  = 9.81       # m/s^2

# Target pressure levels (Pa); 12 levels down to 200 hPa
plev_hPa = [1000, 925, 850, 800, 700, 600, 500, 400, 300, 250, 225, 200]
plev = xr.DataArray(np.array(plev_hPa) * 100.0, dims=("plev",), name="plev")
plev.attrs["units"] = "Pa"

# Load mean files (outputs of Step 3)
dsQ  = xr.open_dataset(f"{MEAN_DIR}/Q_JJ_h03_mean.nc")
dsT  = xr.open_dataset(f"{MEAN_DIR}/T_JJ_h03_mean.nc")
dsZ3 = xr.open_dataset(f"{MEAN_DIR}/Z3_JJ_h03_mean.nc")
dsPS = xr.open_dataset(f"{MEAN_DIR}/PS_JJ_h03_mean.nc")

# Squeeze any lingering length-1 time dims
Q  = dsQ["Q"].squeeze()
T  = dsT["T"].squeeze()
Z3 = dsZ3["Z3"].squeeze()
PS = dsPS["PS"].squeeze()

# Grab hyam/hybm/p0 from any original file that has them
# (search Q h3 file as example)
SAMPLE_GLOB = "/glade/campaign/cesm/development/palwg/pliocene/SVF/b.e13.B1850C5CN.ne120_g16.pliohiRes.002/atm/proc/tseries/hour_3/*cam.h3.Q.*.nc"
sample_files = sorted(glob.glob(SAMPLE_GLOB))
if not sample_files:
    raise FileNotFoundError("Could not find a sample file to read hyam/hybm/P0")
with xr.open_dataset(sample_files[0]) as ref:
    hyam = ref["hyam"]  # lev
    hybm = ref["hybm"]  # lev
    P0   = float(ref["P0"])  # Pa
    lat  = ref["lat"].load()
    lon  = ref["lon"].load()

# Ensure alignment (lev, ncol)
# (If dims are named differently or carry coords, xarray will align by name)
Q, T, Z3 = xr.align(Q, T, Z3, join="exact")

# Moist Static Energy (J/kg)
MSE_hybrid = Q * Lv + T * Cp + Z3 * g
MSE_hybrid = MSE_hybrid.rename("MSE")
MSE_hybrid.attrs.update({
    "long_name": "Moist Static Energy (JJ 03Z mean, hybrid levels)",
    "units": "J kg-1",
})

# Interpolate to fixed pressure levels (GeoCAT)
# data dims expected: (..., lev, ncol)
# ps dims: (..., ncol)
MSE_p = interp_hybrid_to_pressure(
    data=MSE_hybrid,
    ps=PS,
    hyam=hyam,
    hybm=hybm,
    p0=P0,
    new_levels=plev.values,
    method="linear",
)

# Convert to kJ/kg and ensure clean dims
MSE_p = (MSE_p / 1000.0).squeeze()
if "time" in MSE_p.dims:
    MSE_p = MSE_p.isel(time=0, drop=True)
MSE_p = MSE_p.assign_coords(plev=plev.values)  # keep plev as coord

# Grab lat/lon from the mean files (same ncol, avoids spooling to the original)
lat = dsQ["lat"].values  # shape (ncol,)
lon = dsQ["lon"].values  # shape (ncol,)

# Build dataset explicitly with numpy payloads for coords
ds_out = xr.Dataset(
    data_vars={
        "MSE": (("plev", "ncol"), MSE_p.values)
    },
    coords={
        "plev": plev.values,         # Pa
        "lat": ("ncol", lat),        # degrees_north
        "lon": ("ncol", lon),        # degrees_east
    },
    attrs={
        "title": "Plio high-res MSE JJ 03Z mean, interpolated to fixed pressure",
        "note": "Computed from JJ 03Z means of Q,T,Z3,PS; MSE=Q*Lv + T*Cp + Z3*g; converted to kJ/kg",
    },
)

# Keep nice variable metadata
ds_out["MSE"].attrs.update({
    "long_name": "Moist Static Energy (JJ 03Z mean)",
    "units": "kJ kg-1",
})

# Write
os.makedirs(FINAL_NATIVE, exist_ok=True)
out_native = f"{FINAL_NATIVE}/mse_plio_hr_ne120_JJ_h03_mean_interp.nc"
encoding = {"MSE": {"zlib": True, "complevel": 2}}
ds_out.to_netcdf(out_native, format="NETCDF4", encoding=encoding)
print(f"[MSE] Wrote native file: {out_native}")

