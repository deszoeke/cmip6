using Pkg; Pkg.activate(".")

using NCDatasets
using PyPlot
using Statistics
using PyCall
using PyCall: PyObject

# allow for plotting with missing values
function PyObject(a::Array{Union{T,Missing},N}) where {T,N}
    numpy_ma = PyCall.pyimport("numpy").ma
    pycall(numpy_ma.array, Any, coalesce.(a,zero(T)), mask=ismissing.(a))
end

# see also ZarrDatasets

modisfile = joinpath("./data/modis", "MCD06COSP_M3_MODIS.clim.nc")
ds = NCDataset(modisfile)

cf_vars = ["Cloud_Mask_Fraction", "Cloud_Mask_Fraction_Low", "Cloud_Mask_Fraction_Mid", "Cloud_Mask_Fraction_High"]

"""
cl, lat = modis_sect(name, ds=ds, ctrlon=-140, width=0.5) 
return MODIS cloud variable mean
"""
function modis_sect(name, ds=ds, ctrlon=-140, width=0.5)
   lat = ds["latitude"][:]
   lon = ds["longitude"][:]
   filon = findall( abs.( mod.(lon, 360.0) .- mod.(ctrlon, 360.0) ) .<= width )
   filat = findall( abs.(lat) .<= 11)
   x = ds.group[name]["Mean"][filat,filon,:]
   clt = mean(x, dims=2)[:,1,:]
   clt, lat[filat]
end

clt, lat = modis_sect(cf_vars[1])
cllo, _  = modis_sect(cf_vars[2])
clmd, _  = modis_sect(cf_vars[3])
clhi, _  = modis_sect(cf_vars[4])

# stacked area plot of Oct and Apr clouds
stack(m) = [cllo[:,m], clmd[:,m], clhi[:,m]]

fig, axs = subplots(2,1)
axs[1].stackplot(lat, 100 .*stack(10))
axs[1].set_title("October")
axs[2].stackplot(lat, 100 .*stack( 4))
axs[2].set_title("April")
for ax in axs
    ax.set_ylabel("cloud amount (%)")
    ax.set_xlim([-10, 10])
    ax.set_ylim([0, 100])
end
axs[2].set_xlabel("degrees latitiude")
tight_layout()

savefig("modis_cldstack_140w.png")
savefig("modis_cldstack_140w.svg")

"plot the latitude-seasonal cycle"
function seas_lat(lat, tcc_clim, lcc_clim, mcc_clim, hcc_clim;
		  fig=gcf(), tlevs=0.25:0.05:0.85, hlevs=0:0.1:1, llevs=0.16:0.02:0.44, mlevs=hlevs )
	
	mm = @. mod(0:17, 12) + 1

	figure( fig ) # uses the current figure, or the figure passed by keyword
	ax1 = subplot(2,1,1)
	contourf(1:18, lat, tcc_clim[:,mm], levels=tlevs, cmap=ColorMap("bone"))
	colorbar()
	contour(1:18, lat, hcc_clim[:,mm], colors="w", levels=hlevs, linewidths=0.5)
	contour(1:18, lat, hcc_clim[:,mm], colors="w", levels=[0.3], linewidths=1.3)
	xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
	title("cloud fraction climatology")
	ylabel("latitude")

	ax2 = subplot(2,1,2)
	contourf(1:18, lat, lcc_clim[:,mm], levels=llevs, cmap=ColorMap("bone"))
	colorbar()
	contour(1:18, lat, mcc_clim[:,mm], colors="w", levels=mlevs, linewidths=0.5)
	contour(1:18, lat, mcc_clim[:,mm], colors="w", levels=[0.3], linewidths=1.3)
	xticks(1:3:18, ["Jan","Apr","July","Oct","Jan","Apr"])
	ylabel("latitude")

	return gcf(), [ax1, ax2]
end

fig = gcf()
clf()
fig, axs = seas_lat( lat, clt, cllo, clmd, clhi )
axs[1].set_title("MODIS cloud fraction climatology")
figure(fig)		    
savefig("modis_seasonal_cld.png")
savefig("modis_seasonal_cld.svg")
