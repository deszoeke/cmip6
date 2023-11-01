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
                             'area': [10, 0, -10, 90],
                             'time': '00:00',
                             'month': [ '01','02','03','04','05','06','07','08','09','10','11','12'],
                             'day': [ '01', '02', '03', '04', '05', '06',
            			      '07', '08', '09', '10', '11', '12',
            			      '13', '14', '15', '16', '17', '18',
            			      '19', '20', '21', '22', '23', '24',
            			      '25', '26', '27', '28', '29', '30',
            			      '31',],
                             'year': ['1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022'],
                             'variable': 'boundary_layer_height',
                         }
                         """)
#                         'year': ['2010','2011','2012','2013','2014','2015','2016','2017','2018', '2019', '2020', '2021', '2022', '2023'],
r = CDSAPI.retrieve( "reanalysis-era5-single-levels", req , "ERA5-bl-blh-easteq-1993-2022.nc" ) # saves data as .nc file

##
# plot data from local copy
ds = NCDataset("ERA5-bl-blh-easteq-1993-2022.nc")

# use cartopy to make plots # brittle--often fails
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
