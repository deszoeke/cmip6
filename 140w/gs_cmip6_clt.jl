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

## API URL for the bucket
#bucket_url = "https://storage.googleapis.com/storage/v1/b/cmip6/o"
#prefix = "CMIP6/CMIP/NOAA-GFDL/GFDL-ESM4/historical/r1i1p1f1/Amon/clt/gr1/v20190726/"
#
## Send the HTTP GET request
#response = HTTP.get("$bucket_url?prefix=$prefix")
#data = JSON.parse(String(response.body))
#
## Extract file names
#files = [item["name"] for item in data["items"]]
#println(files)


"monthly climatological mean"
clim(x) = mean(reshape(x, (size(x,1),12,size(x,2)÷12)), dims=3)[:,:,1]

"""
climo, lon = get_cmip6_lonclim(url, ctrlon=-140.0, width=2.0)
return climatology lon section from an http zarray dataset
"""
function get_cmip6_lonclim(url, ctrlon=-140.0, width=2.0)
    store = Zarr.zopen(url) # this opens a Google Cloud Storage Zarray datastore
    
    # load lat and lon for subsetting
    lat = store["lat"][:]
    lon = store["lon"][:]
    filon = findall( abs.( mod.(lon, 360.0) .- mod.(ctrlon, 360.0) ) .<= width )
    filat = findall( abs.(lat) .<= 10 )

    # subset
    clt = store["clt"][filon,filat,:]
    # climatology
    x = mean(clt, dims=1)[1,:,:]
    clt_c = clim( x )
    clt_c, lat[filat]
end

## example store open
#store = Zarr.zopen("https://storage.googleapis.com/cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-ESM4/historical/r1i1p1f1/Amon/clt/gr1/v20190726/")
#lat = store["lat"][:]
#lon = store["lon"][:]
#filon = findall( 139 .< (360 .- lon) .< 141 )
#filat = findall( abs.(lat) .<= 10 )
#clt = store["clt"][filon,filat,:]
#x = mean(clt, dims=1)[1,:,:] # average over lon -> (lat, time)
#clt_c = clim( x )

# which CMIP6 models
model_id = ["GFDL-ESM4", "E3SM1.1", "CESM-FV2"]
urls = ["https://storage.googleapis.com/cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-ESM4/historical/r1i1p1f1/Amon/clt/gr1/v20190726/",
        "https://storage.googleapis.com/cmip6/CMIP6/CMIP/E3SM-Project/E3SM-1-1/historical/r1i1p1f1/Amon/clt/gr/v20191211/",
        "https://storage.googleapis.com/cmip6/CMIP6/CMIP/NCAR/CESM2-FV2/historical/r1i1p1f1/Amon/clt/gn/v20191120/" ]

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

