##
using CDSAPI
using NCDatasets
using PyPlot, PyCall

# get cartopy
ccrs = pyimport("cartopy.crs")
feature = pyimport("cartopy.feature")

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
                             'year': ['2018', '2019', '2020', '2021', '2022'],
                             'pressure_level': [ '850', '1000'],
                             'variable': [ 'divergence', 'fraction_of_cloud_cover', 'geopotential',
                                 'potential_vorticity', 'specific_humidity', 'temperature',
                                 'u_component_of_wind', 'v_component_of_wind', 'vertical_velocity',
                                 'vorticity'],
                         }
                         """)
# r = CDSAPI.retrieve( "reanalysis-era5-pressure-levels", req , "era5_as_850_1000.nc" ) # saves data in download.nc

##
# plot data from local copy
ds = NCDatasets.Dataset("era5_as_850_1000.nc")

# test contour vorticity at 850 hPa
# contour(ds["longitude"][:], ds["latitude"][:], ds["vo"][:,:,1,1]')

# use cartopy to make plots
ccrs = pyimport("cartopy.crs")
feature = pyimport("cartopy.feature")

ax = subplot(projection=ccrs.Orthographic(65, 13))
ax.add_feature(feature.OCEAN, color="navy")
ax.add_feature(feature.LAND, color="lightgray")
ax.contour(ds["longitude"][:], ds["latitude"][:], ds["vo"][:,:,1,1]')

