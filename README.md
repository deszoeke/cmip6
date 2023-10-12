# CMIP6 data

I am writing a proposal to use CMIP6 model data. It's available at ESGF, but high volume, so deciding how to download and use it is optimally is tricky.

Here's an http download link:
http://vesg.ipsl.upmc.fr/thredds/fileServer/cmip6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Eday/zmla/gr/v20180803/zmla_Eday_IPSL-CM6A-LR_historical_r2i1p1f1_gr_19950101-20141231.nc

Here's openDAP:
http://vesg.ipsl.upmc.fr/thredds/dodsC/cmip6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Eday/zmla/gr/v20180803/zmla_Eday_IPSL-CM6A-LR_historical_r2i1p1f1_gr_19950101-20141231.nc.dods

I've never used globus, but I recall you recommended it. This the corresponding globus link. What do I do with it? Is there an API, or do globus members pipe it through their systems?
globus:ee351394-6ac7-11e7-a9c0-22000bf2d287/cmip6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Eday/zmla/gr/v20180803/zmla_Eday_IPSL-CM6A-LR_historical_r2i1p1f1_gr_19950101-20141231.nc

I learned there are also AWS S3S ways of accessing the data. But I can't find a minimum example that works for that.

Here's an example that works in Julia.
```julia
using NCDatasets, PyPlot

# IPSL CM6A
ds = Dataset("http://vesg.ipsl.upmc.fr/thredds/dodsC/cmip6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Eday/zmla/gr/v20180803/zmla_Eday_IPSL-CM6A-LR_historical_r2i1p1f1_gr_19950101-20141231.nc")

subplot(2,1,1)
pcolormesh(ds[:lon][:], ds[:lat][:], permutedims(ds[:zmla][:,:,500]))
colorbar()
ds[:time][500]

# NCAR CESM2-FV2
ds = Dataset("http://esgf-data1.llnl.gov/thredds/dodsC/css03_data/CMIP6/CMIP/NCAR/CESM2-FV2/historical/r2i1p1f1/Eday/zmla/gn/v20200226/zmla_Eday_CESM2-FV2_historical_r2i1p1f1_gn_18500101-18591231.nc")

subplot(2,1,2)
pcolormesh(ds[:lon][:], ds[:lat][:], permutedims(ds[:zmla][:,:,50]))
colorbar()
contour(ds[:lon][:], ds[:lat][:], permutedims(ds[:zmla][:,:,50]), levels=[700], colors="w")
ds[:time][50]

```
