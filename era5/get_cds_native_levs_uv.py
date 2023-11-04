#!/usr/bin/env python
import cdsapi

# Requets ERA5 lowest 19 native resolution levels from MARS with cdsapi
c = cdsapi.Client()
c.retrieve('reanalysis-era5-complete', { # Requests follow MARS syntax
                                         # Keywords 'expver' and 'class' can be dropped. They are obsolete
                                         # since their values are imposed by 'reanalysis-era5-complete'
    'date'    : '2011-10-01/to/2011-11-30',            # The hyphens can be omitted
    'levelist': '119/to/137',          # 1 is top level, 137 the lowest model level in ERA5. Use '/' to separate values.
    'levtype' : 'ml',
    'param'   : '131/132',                   # Full information at https://apps.ecmwf.int/codes/grib/param-db/
                                         # The native representation for temperature is spherical harmonics
    'stream'  : 'oper',                  # Denotes ERA5. Ensemble members are selected by 'enda'
    'time'    : '00/to/23/by/6',         # You can drop :00:00 and use MARS short-hand notation, instead of '00/06/12/18'
    'type'    : 'an',
    'area'    : '10/-0/-10/180',          # North, West, South, East. Default: global
    'grid'    : '1.0/1.0',               # Latitude/longitude. Default: spherical harmonics or reduced Gaussian grid
    'format'  : 'netcdf',                # Output needs to be regular lat-lon, so only works in combination with 'grid'!
}, 'ERA5-bl-uv-easteq.nc')     # Output file. Adapt as you wish.

'''
https://confluence.ecmwf.int/display/UDOC/L137+model+level+definitions
ERA5 19 lowest native pressure levels
n   a,Pa        b           ph,hPa      pf,hPa      alt,m   geom,m  T,K     dens,kg/m^3
119	3057.265625	0.873929	916.0815	910.8965	889.17	889.29	282.37	1.123777
120	2659.140625	0.887408	925.7571	920.9193	798.62	798.72	282.96	1.133779
121	2294.242188	0.899900	934.7666	930.2618	714.94	715.02	283.50	1.143084
122	1961.500000	0.911448	943.1399	938.9532	637.70	637.76	284.00	1.151724
123	1659.476563	0.922096	950.9082	947.0240	566.49	566.54	284.47	1.159733
124	1387.546875	0.931881	958.1037	954.5059	500.91	500.95	284.89	1.167147
125	1143.250000	0.940860	964.7584	961.4311	440.58	440.61	285.29	1.173999
126	926.507813	0.949064	970.9046	967.8315	385.14	385.16	285.65	1.180323
127	734.992188	0.956550	976.5737	973.7392	334.22	334.24	285.98	1.186154
128	568.062500	0.963352	981.7968	979.1852	287.51	287.52	286.28	1.191523
129	424.414063	0.969513	986.6036	984.2002	244.68	244.69	286.56	1.196462
130	302.476563	0.975078	991.0230	988.8133	205.44	205.44	286.81	1.201001
131	202.484375	0.980072	995.0824	993.0527	169.50	169.51	287.05	1.205168
132	122.101563	0.984542	998.8081	996.9452	136.62	136.62	287.26	1.208992
133	62.781250	0.988500	1002.2250	1000.5165	106.54	106.54	287.46	1.212498
134	22.835938	0.991984	1005.3562	1003.7906	79.04	79.04	287.64	1.215710
135	3.757813	0.995003	1008.2239	1006.7900	53.92	53.92	287.80	1.218650
136	0.000000	0.997630	1010.8487	1009.5363	30.96	30.96	287.95	1.221341
137	0.000000	1.000000	1013.2500	1012.0494	10.00	10.00	288.09	1.223803
'''

'''
ERA5 parameters
name              shortname paramID
velocity potential  'vp'    1
streamfunction      'strf'  2
potential temperature  'pt' 3
equivalent potential temperature  'eqpt' 4
virt pot temp       'vptmp' 3012
olr top             'role'  300114
olr top clear       'lwtc'  300201
temperature         't'c    130
specific humidity   'q'     133
sst                 'sst'   34
zonal velocity      'u'     131
meridional velocity 'v'     132
column water vapor  'tcwv'  137
boundary layer height 'blh' 159
'''
