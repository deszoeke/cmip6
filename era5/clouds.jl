using NCDatasets
using Dates
using Statistics
using PyPlot

datapath = expanduser("~/data/era5/cloud")
ds = NCDataset(joinpath(datapath, "era5_cloud_m.nc"))
lat = ds["latitude"]
lon = ds["longitude"]
ctrlon = -140.0
width = 0.5
filat = findall( abs.(lat) .<= 11.0 )
filon = findall( abs.( mod.(lon, 360.0) .- mod.(ctrlon, 360.0) ) .<= width )
dt  = ds["valid_time"][:]
x   = mean(ds["tcc"][filon,filat,:], dims=1)[1,:,:] # lon,lat,time
xtract(var) = mean(ds[var][filon,filat,:], dims=1)[1,:,:]

# default functions for meanbin
g(x) = !ismissing(x) # is good data
f(x) = g(x) ? x : 0  # add if good data, otherwise add zero

#function meanbin(x, b, f=f, g=g, dim=3)
function meanbin(x::Array, b::Array{T}; f=f, g=g, dim=3) where T<:Integer
   nd = length(size(x))
   sza = Tuple((i!=dim) ? size(x)[i] : maximum(b) for i in 1:nd)
   a = zeros(sza)
   c = zeros(sza)
   # loop over all indices of x with CartesianIndices
   for ci in CartesianIndices(x)
      # loops dimensions of ci, replacing dim'th dimension with bin index b
      bi = CartesianIndex(((i!=dim) ? ci[i] : b[ci[i]] for i in 1:nd)...)
      a[bi] += f( x[ci] )
      c[bi] += g( x[ci] )
   end
   return a./c
end

# short run to precompile
xxx = meanbin( x[1:3,1:3], round.(Int8, month.(dt[1:3])) )

# climatological average along time dim
mon = round.(Int8, month.(dt))
tcc_clim = meanbin( x, mon, dim=2 )
hcc_clim = meanbin( xtract("hcc"), mon, dim=2 )
mcc_clim = meanbin( xtract("mcc"), mon, dim=2 )
lcc_clim = meanbin( xtract("lcc"), mon, dim=2 )

mm = @. mod(0:17, 12)+1
clf()
subplot(2,1,1)
contourf(1:18, lat[filat], tcc_clim[:,mm], levels=0.25:0.05:0.75, cmap=ColorMap("bone"))
#contour(1:18, lat[filat], lcc_clim[:,mm], colors="k", levels=0.1:0.1:0.4, linewidths=1)
#pcolormesh(1:18, lat[filat], tcc_clim[:,mm])
colorbar()
#contour(1:18, lat[filat], hcc_clim[:,mm].+mcc_clim[:,mm], colors="w", levels=0:0.1:1)
contour(1:18, lat[filat], hcc_clim[:,mm], colors="w", levels=0:0.1:1, linewidths=0.5)
contour(1:18, lat[filat], hcc_clim[:,mm], colors="w", levels=[0.3], linewidths=1.3)
xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
title("ERA5 140W cloud fraction climatology") 
ylabel("latitude")

subplot(2,1,2)
contourf(1:18, lat[filat], lcc_clim[:,mm], levels=0.16:0.02:0.44, cmap=ColorMap("bone"))
#contour(1:18, lat[filat], lcc_clim[:,mm], colors="k", levels=0.1:0.1:0.4, linewidths=1)
#pcolormesh(1:18, lat[filat], tcc_clim[:,mm])
colorbar()
contour(1:18, lat[filat], mcc_clim[:,mm], colors="w", levels=0:0.1:1, linewidths=0.5)
contour(1:18, lat[filat], mcc_clim[:,mm], colors="w", levels=[0.3], linewidths=1.3)
xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
ylabel("latitude")

savefig("era5_cloud.png")
savefig("era5_cloud.svg")

