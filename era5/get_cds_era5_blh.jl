##
using Pkg
Pkg.activate("..")

##
using CDSAPI
using NCDatasets
using Statistics
using PyPlot, PyCall

##
# download ERA5 data from Copernicus Climate Data Store CDS API
req = CDSAPI.py2ju("""
                         {
                             'product_type': 'reanalysis',
                             'format': 'netcdf',
                             'area': [30, 40, -4, 90],
                             'time': '00:00',
                             'month': [ '05', '06' ],
                             'day': [ '01', '02', '03', '04', '05', '06',
            			      '07', '08', '09', '10', '11', '12',
            			      '13', '14', '15', '16', '17', '18',
            			      '19', '20', '21', '22', '23', '24',
            			      '25', '26', '27', '28', '29', '30',
            			      '31',],
                             'year': ['2018', '2019', '2020', '2021', '2022', '2023'],
                             'variable': 'boundary_layer_height',
                         }
                         """)
# r = CDSAPI.retrieve( "reanalysis-era5-single-levels", req , "era5_as_blh.nc" ) # saves data as .nc file

##
# plot data from local copy
ds = NCDatasets.Dataset("era5_as_blh.nc")

# use cartopy to make plots
ccrs = pyimport("cartopy.crs")
feature = pyimport("cartopy.feature")

# mooring locations
ad = ((68.5,12), (69,15), (67.5,18.5))
adlon = [x[1] for x in ad]
adlat = [x[2] for x in ad]

# plot
ax = subplot(projection=ccrs.Orthographic(65, 13))
# ax.add_feature(feature.OCEAN, color="navy")
ax.add_feature(feature.LAND, color="lightgray")
im = ax.contour(ds["longitude"][:], ds["latitude"][:], mean(ds["blh"][:,:,:], dims=(3))[:,:,1]', levels=300:50:900)
colorbar(im)
xtl = ax.get_xlim()[1] : 10 : ax.get_xlim()[2]
ax.set_xticks(xtl)
ytl = ax.get_ylim()[1] : 10 : ax.get_ylim()[2]
ax.set_yticks(ytl)
ax.plot(adlon,adlat, linestyle="none", marker="^", color="orange") 
