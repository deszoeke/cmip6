using GoogleCloud
using NCDatasets

# Define the public bucket and object path
bucket_name = "cmip6" #"gcp-public-data-cmip6"
file_path = "CMIP6/CMIP/NOAA-GFDL/GFDL-ESM4/historical/r1i1p1f1/Amon/clt/gr1/v20190726"
filename = "clt_Amon_GFDL-ESM4_historical_r1i1p1f1_gr1_185001-201412.nc"
#"CMIP6/ScenarioMIP/NCAR/CCSM4/ssp245/r1i1p1f1/Amon/tas/gr/v20200731/tas_Amon_CCSM4_ssp245_r1i1p1f1_gr_201501-210012.nc"
# Download a local NetCDF file
#local_file = "tas_Amon_CCSM4_ssp245.nc"
#GCS.download(bucket_name, file_path, local_file)

zarr_url = "https://storage.googleapis.com/cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-ESM4/historical/r1i1p1f1/Amon/clt/gr1/v20190726/clt/.zarray"

# form a URL for NCDatasets 
url = joinpath("https://storage.googleapis.com", bucket_name, file_path, filename)
ds = NCDataset(url)
