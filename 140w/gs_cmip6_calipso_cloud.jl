# Load CMIP6 CESM-FV2, GFDL-ESM4, E3SM1.1 total cloud cover clt and 
# plot latitude section at 140 W.
#
# Simon de Szoeke
# (c) 2024-12-08

cd(joinpath(homedir(), "Projects/cmip6/140w"))
using Pkg; Pkg.activate(".")

using HTTP
using JSON
using Zarr
using Statistics
using PyPlot

# allow for plotting with missing values
function PyObject(a::Array{Union{T,Missing},N}) where {T,N}
    numpy_ma = PyCall.pyimport("numpy").ma
    pycall(numpy_ma.array, Any, coalesce.(a,zero(T)), mask=ismissing.(a))
end

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
    filat = findall( abs.(lat) .<= 11.0 )

    # subset
    clt = store[var][filon,filat,:]
    # climatology
    x = mean(clt, dims=1)[1,:,:]
    clt_c = clim( x )
    clt_c, lat[filat]
end


# which CMIP6 models
center_id = ["NOAA-GFDL", "E3SM-Project", "NCAR"]
model_id = ["GFDL-CM4", "E3SM-1-1", "CESM-FV2"]
# E3SM only has albisccp and cllcalipso
# CESM only has hur and hus

# which CFmon variables
var = ["clt", "cll", "clm", "clh"]
variable_id = var .* "calipso"

url_base = "https://storage.googleapis.com"
url_test = joinpath(url_base, "cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-CM4/historical/r1i1p1f1/CFmon/cltcalipso/gr1/v20180701")
# url = joinpath(url_base, "cmip6/CMIP6/CFMIP/NOAA-GFDL/GFDL-CM4/aqua-control-lwoff/r1i1p1f1/CFmon/cltcalipso/gr1/v20180701")
# url(variable_id) = joinpath(url_base, "cmip6/CMIP6/CMIP/$(center_id)/$(model_id)/historical/r1i1p1f1/CFmon/$(variable_id)/gr1/v20180701")

# load cloud climatology data into clt_c Vector[model]{Vector[lat]}
# clt_c = Vector{Array}(undef, 3)
# lat   = Vector{Vector}(undef, 3)

# load just NOAA GFDL-CM4 cloud fraction data
gfdl = Dict()
# for i in eachindex(urls)[1] 
#     clt_c[i], lat[i] = get_cmip6_lonclim(urls[i])
# end
let (center_id, model_id) = (center_id[1], model_id[1])
    print("$(center_id)/$(model_id)")
    for (i, v) in enumerate(var[2:end]) # loop through variables
        url = joinpath(url_base, "cmip6/CMIP6/CMIP/$(center_id)/$(model_id)/historical/r1i1p1f1/CFmon/$(variable_id[i])/gr1/v20180701")
        gfdl[v], gfdl["lat"] = get_cmip6_lonclim(url, variable_id[i])
    end
end

"plot the latitude-seasonal cycle"
function seas_lat(lat, tcc_clim, lcc_clim, mcc_clim, hcc_clim; 
    fig=gcf(), tlevs=0.25:0.05:0.85, hlevs=0:0.1:1, llevs=0.16:0.02:0.44, mlevs=hlevs )
	
	mm = @. mod(0:17, 12) + 1

	figure( fig ) # uses the current figure, or the figure passed by keyword
	ax1 = subplot(2,1,1)
	contourf(1:18, lat, tcc_clim[:,mm], levels=tlevs, cmap=ColorMap("bone"))
	ax1.set_facecolor("xkcd:chocolate brown")
    colorbar()
    contour(1:18, lat, tcc_clim[:,mm], levels=0.10:0.05:0.20, colors="firebrick", linewidths=1.3)
	contour(1:18, lat, hcc_clim[:,mm], colors="w", levels=hlevs, linewidths=0.5)
	contour(1:18, lat, hcc_clim[:,mm], colors="w", levels=[0.2], linewidths=1.3)
	xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
	# title("cloud fraction climatology")
	ylabel("latitude")

	ax2 = subplot(2,1,2)
	contourf(1:18, lat, lcc_clim[:,mm], levels=[llevs; 1.0], vmax=llevs[end], cmap=ColorMap("bone"))
    ax2.set_facecolor("xkcd:chocolate brown")
    colorbar()
    contour(1:18, lat, lcc_clim[:,mm], levels=0.46:0.02:1.0, colors="firebrick", linewidths=0.4)
    contour(1:18, lat, lcc_clim[:,mm], levels=0.5:0.1:1.0, colors="firebrick", linewidths=1.0)
	contour(1:18, lat, mcc_clim[:,mm], colors="w", levels=mlevs, linewidths=0.5)
	contour(1:18, lat, mcc_clim[:,mm], colors="w", levels=[0.2], linewidths=1.3)
	xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
	ylabel("latitude")

	return gcf(), [ax1, ax2]
end

fig = gcf()
clf()
fig, axs = seas_lat(gfdl["lat"], gfdl["clt"]/100, gfdl["cll"]/100, gfdl["clm"]/100, gfdl["clh"]/100 ) #; tlevs=0.05:0.05:0.85, hlevs=0:0.1:1, llevs=0.16:0.02:0.44 )
fig.suptitle("NOAA GFDL-CM4 cloud fraction climatology")
axs[1].set_title("total (shaded), high (contour 0.1)")
axs[2].set_title("low (shaded), mid (contour 0.1)")
tight_layout()
figure(fig)

savefig("gfdl-cm4_seasonal_cld.png")
savefig("gfdl-cm4_seasonal_cld.svg")