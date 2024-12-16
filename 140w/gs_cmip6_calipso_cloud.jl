# Load CMIP6 CESM-FV2, GFDL-ESM4, E3SM1.1 total cloud cover clt and 
# plot latitude section at 140 W.
#
# Simon de Szoeke
# (c) 2024-12-08

using Pkg; Pkg.activate(".")

using HTTP
using JSON
using Zarr
using Statistics
using PyPlot


"monthly climatological mean"
clim(x) = mean(reshape(x, (size(x,1),12,size(x,2)÷12)), dims=3)[:,:,1]

"""
climo, lon = get_cmip6_lonclim(url, ctrlon=-140.0, width=2.0)
return climatology lon section from an http zarray dataset
"""
function get_cmip6_lonclim(url, var, ctrlon=-140.0, width=2.0)
    store = Zarr.zopen(url) # this opens a Google Cloud Storage Zarray datastore
    
    # load lat and lon for subsetting
    lat = store["lat"][:]
    lon = store["lon"][:]
    filon = findall( abs.( mod.(lon, 360.0) .- mod.(ctrlon, 360.0) ) .<= width )
    filat = findall( abs.(lat) .<= 10 )

    # subset
    clt = store[var][filon,filat,:]
    # climatology
    x = mean(clt, dims=1)[1,:,:]
    clt_c = clim( x )
    clt_c, lat[filat]
end


# which CMIP6 models
center_id = ["NOAA-GFDL", "E3SM-Project", "NCAR"]
model_id = ["GFDL-CM4", "E3SM1.1", "CESM-FV2"]

# which CFmon variables
var = ["clt", "cll", "clm", "clh"]
variable_id = var .* "calipso"

url_base = "https://storage.googleapis.com"
# url = joinpath(url_base, "cmip6/CMIP6/CFMIP/NOAA-GFDL/GFDL-CM4/aqua-control-lwoff/r1i1p1f1/CFmon/cltcalipso/gr1/v20180701")
url(varid) = joinpath(url_base, "cmip6/CMIP6/CMIP/$(center_id)/$(model_id)/historical/r1i1p1f1/CFmon/$(variable_id)/gr1/v20180701")

# load cloud climatology data into clt_c Vector[model]{Vector[lat]}
clt_c = Vector{Array}(undef, 3)
lat   = Vector{Vector}(undef, 3)
for i in eachindex(urls)
    clt_c[i], lat[i] = get_cmip6_lonclim(urls[i])
end

# visualize lat section for the models
fig, axs= subplots(2,1)
for i in eachindex(lat)
    axs[1].plot(lat[i], clt_c[i][:,10], label=model_id[i], marker=".")
    axs[2].plot(lat[i], clt_c[i][:, 4], label=model_id[i], marker=".")
end
axs[1].legend(frameon=false)
axs[1].set_title("October")
axs[2].set_title("April")
for i in 1:2
    axs[i].set_ylabel("cloud fraction (%)")
    axs[i].set_ylim([35, 90])
end
tight_layout()
savefig("cmip6_140w_clt_octapr.png")
savefig("cmip6_140w_clt_octapr.svg")

