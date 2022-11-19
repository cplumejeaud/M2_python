# -*- coding: utf-8 -*-
"""
Created on Wed Nov  9 14:31:08 2022

@author: cplume01
"""

import xarray as xr
import pandas as pd
import numpy as np
#import pandas.io.sql as sql
from sqlalchemy import create_engine

engine = create_engine('postgresql://postgres:aqua_77@localhost:8005/jason3')

file = r'C:\Travail\CNRS_poitiers\Cours\Cours_M2_python\2022\code\ideeTP\JA3_GPN_2PfP310_070_20220730_030014_20220730_035627.nc'
#file = r'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627.nc'
ds = xr.open_dataset(file,group='data_20')

ds.variables #xarray.core.utils.Frozen
print(type(ds.variables))

def save_variable_metadata () : 

    for k in ds.variables:
        print(k)
        print(type(k))
        #print(ds[k])
        print(ds[k].attrs)
        
        comment = None
        unit = None
        standard_name = None
        long_name = None
        
        print(ds[k].attrs)
        if 'units' in ds[k].attrs.keys():
            #print(ds[k].attrs['units'])
            #units.append(ds[k].attrs['units']) 
            unit = ds[k].attrs['units']
        if 'standard_name' in ds[k].attrs.keys():
            #print(ds[k].attrs['units'])
            #standard_name.append(ds[k].attrs['standard_name']) 
            standard_name = ds[k].attrs['standard_name']
        if 'long_name' in ds[k].attrs.keys():
            #print(ds[k].attrs['units'])
            #comments.append(ds[k].attrs['comments'])
            long_name = ds[k].attrs['long_name']
        if 'comment' in ds[k].attrs.keys():
            #print(ds[k].attrs['units'])
            #comments.append(ds[k].attrs['comments'])
            comment = ds[k].attrs['comment']
    
        
        # Code qui fait un insert si if it not None, insert
        # save in SQL
        with engine.connect() as con:
            query = """insert into variable (varname, varunit, commentaires, standard_name, longname) values ('%s','%s','%s', '%s','%s');""" % (k, unit, comment, standard_name, long_name)
            rs = con.execute(query)
        
        #print(type(ds[k].attrs))
        #print(ds[k].values())

"""
Attributes
long_name:      20 Hz latitude
standard_name:  latitude
units:          degrees_north
comment: 
    """
def save_track() : 
    ## Renseigne la track
    
    trackname = 'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627'
    print(trackname.split('_')[3])
    indice = trackname.split('_')[3]
    date_min = ds.time.min().values
    date_max = ds.time.max().values
    
    longmax = ds.longitude.max()
    longmin = ds.longitude.min()
    latmax = ds.latitude.max()
    latmin  = ds.latitude.min()
    
    query = """insert into track (identifiant, indice, numero, date_min, date_max, boundingbox) values ('%s', '%s', '%s'::int, '%s', '%s', ST_MakeEnvelope(%f, %f, %f, %f, 4326) )""" % (trackname, indice, indice, date_min, date_max, longmin, latmin, longmax, latmax)
    print(query)
    
    with engine.connect() as con:
        rs = con.execute(query)


trackid = 'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627'
i = 0
df = pd.DataFrame()

df['altitude'] = ds.altitude.values
df['distance_to_coast'] = ds.distance_to_coast.values
df['meteo_measurement_altitude_interp_qual'] = ds.meteo_measurement_altitude_interp_qual.values
df['model_dry_tropo_cor_measurement_altitude'] = ds.model_dry_tropo_cor_measurement_altitude.values
df['model_wet_tropo_cor_measurement_altitude'] = ds.model_wet_tropo_cor_measurement_altitude.values
df['surface_slope_cor'] = ds.surface_slope_cor.values
df['time'] = ds.time.values
df['longitude'] = ds.longitude.values
df['latitude'] = ds.latitude.values
df['trackid'] = trackid
df['ptid'] = np.arange(1,df.shape[0]+1,1)

print(df)
print(df.columns)
print(df.shape)

df.to_sql('trackdata', con=engine.connect(), if_exists='replace')

def bidon() : 
    for k in ds.altitude:
        #print(k)
        #print(type(k))
        df[0]['altitude'] = k.values
        #print(k.values) ## a enregistrer dans varvalues.value avec le non ptid et le bon varid
        """
        print(k.coords['time'].values)
        print(k.coords['latitude'].values)
        print(k.coords['longitude'].values)
        """
        datetime = k.coords['time'].values
        lat = k.coords['latitude'].values
        long = k.coords['longitude'].values
        
        trackid = 'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627'
        query = """insert into pointtime (trackid, long, lat, datetime )
            values ('%s', %f, %f, '%s')""" % (trackid, long, lat, datetime)
        with engine.connect()  as con:
            rs = con.execute(query) 
            #print(rs.fetchone())
            
            #print(type(rs))
            print(str(i) + 'insert point :')
        i = i+1 
        #distance = ds.distance_to_coast.sel(time= datetime)
        
        #print(distance.values)
    
    #.execution_options(         isolation_level="REPEATABLE READ")


"""
distance_to_coast
meteo_measurement_altitude_interp_qual
altitude
model_dry_tropo_cor_measurement_altitude
model_wet_tropo_cor_measurement_altitude
surface_slope_cor
"""


