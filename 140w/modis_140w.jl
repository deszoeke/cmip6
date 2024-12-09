using Pkg; Pkg.activate(".")

using NCDatasets
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

savefig("modis_140w.png")
savefig("modis_140w.svg")

