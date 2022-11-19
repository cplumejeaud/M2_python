# -*- coding: utf-8 -*-
"""
Created on Thu Oct 20 08:33:11 2022

@author: cplume01
"""

from geopy.geocoders import Nominatim
import pandas as pd
import pandas.io.sql as sql
from sqlalchemy import create_engine
import json

import time

#geopy.geocoders.options.default_user_agent = "my-application"

def test_une_adresse(adress="175 5th Avenue NYC"):
    
    #https://operations.osmfoundation.org/policies/nominatim/
    #Read with caution usage conditions
    geolocator = Nominatim(user_agent="test_christine")
    location = geolocator.geocode(adress)
    
    if location is not None:
        #print(location.address)
        #Flatiron Building, 175, 5th Avenue, Flatiron, New York, NYC, New York, ...
        
        print((location.latitude, location.longitude))
        #(40.7410861, -73.9896297241625)
    
        #print(location.raw)
        return location.raw
    else:
        return None
    
def get_data_togeocode() :
    '''
    you read the database and get adresses
    return a dataframe
    '''
    engine = create_engine('postgresql://postgres:postgres@localhost:5435/logement')

    query = """ select distinct nom_usine, adresse, code_postal, nom_de_la_commune 
        from theses.usine_complet uc, laposte_base lb
        where lb.code_commune_insee  = uc.code_insee::text  and failed is false and lat is null
        order by uc.nom_usine , code_postal """
    df = sql.read_sql_query(query, engine)
    
    return df

if __name__ == '__main__':
    
    df = get_data_togeocode()
    
    #Connection pour la sauvegarde des fichiers SQL
    engine = create_engine('postgresql://postgres:postgres@localhost:5435/logement')

    
    data = []
    
    geojson = {"type": "FeatureCollection", "features": []}


    i = 0
    for index, row in df.iterrows():
        print(str(i) + "-------------------------")
        adresse = row.adresse+', '+row.code_postal+', '+row.nom_de_la_commune+', '+'France'
        print(adresse)
        location = test_une_adresse(adresse)
        #print(location["lat"])
        #print(location["lon"])
        #print(location["display_name"])
        #print(location["type"])
        #print(location["importance"])
        
        i = i+1
        time.sleep(1.2)

        if location is not None:
            # initialize list of lists
            infos = [row.nom_usine, location["lat"], location["lon"], location["display_name"], location["type"], location["importance"]]
            data.append(infos)
            
            #Create a feature
            feature = {"type": "Feature", "geometry": {"type": "Point", "coordinates": [location['lon'], location["lat"]]}, "properties": {"adresse": location['display_name'], "nom_usine": row.nom_usine, "type": location['type'],"importance": location['importance']}}
            geojson['features'].append(feature)
            
            # save in SQL
            with engine.connect() as con:
                query = """update theses.usine_complet g 
                    set lat=%f, long=%f , display_name='%s', type_place='%s', importance=%f
                    where g.nom_usine ='%s'""" % (float(location["lat"]), float(location["lon"]), location["display_name"].replace("'", "''"), location["type"], float(location["importance"]), row.nom_usine.replace("'", "''"))
                rs = con.execute(query)

        else:
            # save in SQL
            with engine.connect() as con:
                query = """update theses.usine_complet g 
                    set failed=True
                    where g.nom_usine ='%s'""" % (row.nom_usine.replace("'", "''"))
                rs = con.execute(query)
        
    # Create the pandas DataFrame
    resultat = pd.DataFrame(data, columns=['nom_usine', 'lat', 'lon', 'display_name', 'type', 'importance'])
    
    # Export en csv
    resultat.to_csv('usines_adresses.csv');
    
    
    #Export en geojson    
    with open('usines_adresses.geojson', 'w') as fp:
        json.dump(geojson, fp)    
    