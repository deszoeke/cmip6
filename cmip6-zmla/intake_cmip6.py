import intake

# See intake-esm documentation at
# https://intake-esm.readthedocs.io/en/latest/how-to/understand-keys-and-how-to-change-them.html
# A more comprehensive catalog of CMIP6 data is suggested by
# https://gallery.pangeo.io/repos/pangeo-gallery/cmip6/intake_ESM_example.html
cat_url = "https://storage.googleapis.com/cmip6/pangeo-cmip6.json"
col = intake.open_esm_datastore(cat_url)
# filter results for well known US models
cat = col.search(source_id=["GFDL-CM4", "CESM2-FV2", "E3SM-1-0"], experiment_id='historical', member_id="r1i1p1f1", table_id='Amon', grid_label=["gr", "gn"])
cat.df # show results

cat_subset = cat.search(variable_id="clt")
#dsets = cat_subset.to_dataset_dict()
#dset_dict = cat.to_dataset_dict(zarr_kwargs={'consolidated': True})
#list(dset_dict.keys())
# these data sets not found!

# To find google hosted datasets, browse here
# https://console.cloud.google.com/storage/browser/cmip6/CMIP6/CMIP/E3SM-Project/E3SM-1-1/historical/r1i1p1f1/Amon/clt/gr/v20191211/clt;tab=objects?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&inv=1&invt=Abjbtw&prefix=&forceOnObjectsSortingFiltering=false
gsurl = "gs://cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-CM4/historical/r1i1p1f1/Amon/clt/gr1/v20180701/clt/.zarray" # doesn't seem to work
pub_cat_urls = ["https://storage.googleapis.com/cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-CM4/historical/r1i1p1f1/Amon/clt/gr1/v20180701/clt/.zarray", "https://storage.googleapis.com/cmip6/CMIP6/CMIP/E3SM-Project/E3SM-1-1/historical/r1i1p1f1/Amon/clt/gr/v20191211/clt/.zarray", "https://storage.googleapis.com/cmip6/CMIP6/CMIP/NCAR/CESM2-FV2/historical/r1i1p1f1/Amon/clt/gn/v20191120/clt/.zarray"]

cat = intake.open_esm_datastore(pub_cat_urls[0])

# example from
#https://pangeo-data.github.io/pangeo-cmip6-cloud/accessing_data.html
import matplotlib.pyplot as plt
import datetime
import gcsfs
import xarray as xr

# Connect to Google Cloud Storage
fs = gcsfs.GCSFileSystem(token='anon', access='read_only')

# create a MutableMapping from a store URL
#mapper = fs.get_mapper("gs://cmip6/CMIP6/CMIP/AS-RCEC/TaiESM1/historical/r1i1p1f1/Amon/hfls/gn/v20200225/")
google_urls = [ "gs://cmip6/CMIP6/CMIP/NOAA-GFDL/GFDL-CM4/historical/r1i1p1f1/Amon/clt/gr1/v20180701", "gs://cmip6/CMIP6/CMIP/E3SM-Project/E3SM-1-1/historical/r1i1p1f1/Amon/clt/gr/v20191211", "gs://cmip6/CMIP6/CMIP/NCAR/CESM2-FV2/historical/r1i1p1f1/Amon/clt/gn/v20191120" ]
mapper = fs.get_mapper(google_urls[1])

# make sure to specify that metadata is consolidated
ds = xr.open_zarr(mapper, consolidated=True)
# make climatology the xrpythonic way
clim = ds.groupby('time.month').mean('time')


plt.contour(clim["lon"], clim["lat"], clim.clt[9,:,:])

