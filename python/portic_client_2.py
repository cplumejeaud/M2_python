# -*- coding: utf-8 -*-
"""
Created on Mon Oct 17 18:17:08 2022
Updated on 31/10/2023
@author: Christine PLUMEJEAUD-PERREAU, U.M.R 7301 MIGRINTER
Master 2 course : Web programming with python
"""
#import http.client
#from io import StringIO, BytesIO, TextIOWrapper
import json
import pandas as pd
import geopandas as gpd

import requests





data_local = True
if data_local : 
    #filename = "C:\Travail\Enseignement\Cours_M2_python\Exemple\ports.json"
    filename = "C:/Travail/Enseignement/Cours_M2_python/2023/code/resultats/export3_port_geojson.geojson"
    output = open(filename, "r")
    data = json.load(output)
else:
    ##Ancienne méthode
    """
    print("Ancienne méthode")
    conn = http.client.HTTPConnection("data.portic.fr")
    conn.request("GET", "/api/ports/?shortenfields=false&both_to=false&date=1787")
    r1 = conn.getresponse()
    print(r1.status, r1.reason)
    print(r1)

    data1 = r1.read()  # This will return entire content.
    type(data1) #bytes
    b = BytesIO(data1)
    b.seek(0) #Start of stream (the default).  pos should be  = 0;
    data = json.load(b)
    type(data)
    """
    
    
    ## Nouvelle méthode
    ## https://requests.readthedocs.io/en/latest/
    print("Nouvelle méthode")
    url = "http://data.portic.fr/api/ports/"
    #?shortenfields=false&both_to=false&date=1787"
    r = requests.get(url)
    #print(r.text)
    print(type(r.json()))
    data = r.json()


#data is of <class 'list'>
df = pd.DataFrame(data)

print(df.shape) #(1426, 25)
print(df.head())

print(df.admiralty.unique())
print(df.admiralty.unique().size)

print(df.state_1789_fr.isnull().values.any()) #True 


# Dealing with null values
df.admiralty.isnull().values.any() #True 
values = {'admiralty': 'X', 'state_1789_fr' : 'UNKNOWN'}
df = df.fillna(value=values)
df.admiralty.isnull().values.any() #False 


print(df.state_1789_fr.isnull().values.any()) #True 


print(df.admiralty.unique())
print(df.admiralty.unique().size)


# Listing of admiralties
df.admiralty.unique() # array(['X'], dtype=object)
df.admiralty.unique().size #52

#print(df)
# How many ports by admiralty ?
res = df.groupby('admiralty')['ogc_fid'].count()
print(res)
# How many ports by state_1789_fr ?
res = df.groupby('state_1789_fr')['ogc_fid'].count()
print(res)


print(df.columns)

# Post cours 2023, to show and manipulate geodataframes


#Renommer des colonnes
#x en long
#y en lat
df.rename(columns={'x':'long', 'y':'lat'}, inplace=True)
print(df.columns)

# Build a true geopandas dataframe
#https://geopandas.org/en/stable/gallery/create_geopandas_from_pandas.html 
gdf = gpd.GeoDataFrame(
    df, geometry=gpd.points_from_xy(df.long, df.lat), crs="EPSG:4326"
)

print(gdf.columns)
ports = gdf[['uhgs_id', 'lat', 'long', 'toponyme_standard_fr', 'admiralty', 'status', 'province', 'substate_1789_fr', 'state_1789_fr', 'geometry']]
print(ports.shape)#1700 rows, 10 cols
