# -*- coding: utf-8 -*-
"""
Created on Fri Oct 21 13:53:12 2022
Do the mapping of papa Oumar data

@author: cplume01
"""


import pandas as pd
import requests
import folium
import numpy as np


def read_data() :
    with open('resultat_geocodage.csv', encoding="utf-8") as f:
        # Lecture des données avec la fonction 'read_csv'
        df = pd.read_csv(f, sep=';', decimal=',')
    return df
    
#print(df.groupby(['admiralty']).count())

#print(df.groupby((['shiparea'])).count())

####################### Sol Benjamin
df = read_data()

m = folium.Map(location=[46.34015, 2.60254], zoom_start=6, tiles="Stamen Terrain")
#filter
#▼subset=df[df['state_1789_fr']=='France']
#subset.reset_index(drop=True, inplace=True)

a=df.nom_usine
b=df.long
c=df.lat

for i in range(len((df.nom_usine))):
    folium.Marker(
        location=[c[i], b[i]],
        popup=a[i],
        icon=folium.Icon(icon="Waypoint"),
    ).add_to(m)



m.save("index.html")



####################### Sol Nushrat

m = folium.Map(location=[46.580224, 0.340375],tiles="Stamen Terrain", zoom_start=9)
m.add_child(folium.LatLngPopup())
m.add_child(folium.ClickForMarker(popup="Waypoint"))

for x,y,name,state,adm,adresse,badad,insee in zip(df.long,df.lat,df.nom_usine,df.failed,df.Fermeture, df.display_name, df.adresse, df.code_insee):
    #popup
    textPopup = f"<i>Fermeture en {adm}</i>"
    if  pd.isnull(adm) :
        textPopup = f"<i>Date de fermeture inconnue</i>"
    #bien localisé ou pas
    if state is False:
        textPopup = f"<b>Adresse : </b>{adresse}<br>"+textPopup
        popup=folium.Popup(textPopup, max_width=len(textPopup)*20)
                    
        folium.Marker([y, x], popup=popup, tooltip=name,icon=folium.Icon(color="green"), maxWidth=500).add_to(m)
    else:
        textPopup = f"<b>Adresse : </b>{badad} - INSEE : {insee}<br>"+textPopup
        popup=folium.Popup(textPopup, max_width=len(textPopup)*20)
        folium.Marker([y, x], popup=popup, tooltip=name, maxWidth=500).add_to(m)
m.save("map_usines.html")




###################
## Code SQL
##################

"""
#C:\Travail\CNRS_poitiers\MIGRINTER\Labo\Papa_Oumar_Ndiaye\papa_oumar_geocodage.sql

select * from laposte_base lb ;
-- code_postal

-- import DBeaver des données dans le schéma theses de la BDD logement

alter table theses.usine_complet  drop column "Column6";
alter table theses.usine_complet  rename column "Nom de l'usine" to Nom_usine;
alter table theses.usine_complet  rename column "Adresse" to adresse;
alter table theses.usine_complet  rename column "Code postal INSEE" to code_INSEE;
ALTER TABLE theses.usine_complet RENAME COLUMN "État actuel" TO etat_actuel;


select * from theses.usine_complet uc 

select * from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text 
order by uc.nom_usine , code_insee;
-- 214

alter table theses.usine_complet  add column lat float;
alter table theses.usine_complet  add column long float;
alter table theses.usine_complet  add column display_name text;
alter table theses.usine_complet  add column type_place text;
alter table theses.usine_complet  add column importance float;
alter table theses.usine_complet  add column failed boolean default false;

update theses.usine_complet set failed = true where nom_usine = '1819 - MÉTALLURGIE - MANUFACTURE ARMES' ;

select * from theses.usine_complet where failed is false;--100
select * from theses.usine_complet where failed is true;--37

select * from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text and failed is true
order by uc.nom_usine , code_insee;

select distinct nom_usine, adresse, code_postal, nom_de_la_commune 
from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text and nom_usine = '1966 - SOCIÉTÉ DUDOGNON - EQUIPEMENTIER ELECTRO ACOUSTIQUE'
order by uc.nom_usine , code_postal;
-- 139

select  length(coordonnees_gps), strpos( coordonnees_gps, ','), substring(coordonnees_gps,  4 , length(coordonnees_gps)-4) from laposte_base lb limit 2;
-- (2:46.999873398,6.498147193)
select  length(coordonnees_gps), substring(coordonnees_gps,  4 ) from laposte_base lb limit 2;

select coordonnees_gps, 
substring(coordonnees_gps,  4 , strpos( coordonnees_gps, ',')-4) as lat, 
substring(coordonnees_gps,  strpos( coordonnees_gps, ',')+1, strpos(coordonnees_gps,')')-strpos( coordonnees_gps, ',')-1) as long,
strpos(coordonnees_gps,')')-strpos( coordonnees_gps, ',')-1 as diff
from laposte_base lb limit 2;
-- strpos(coordonnees_gps,')')

select uc.nom_usine , lb.coordonnees_gps , 
substring(coordonnees_gps,  4 , strpos( coordonnees_gps, ',')-4) as lat, 
substring(coordonnees_gps,  strpos( coordonnees_gps, ',')+1, strpos(coordonnees_gps,')')-strpos( coordonnees_gps, ',')-1) as long
from theses.usine_complet uc, laposte_base lb,
(select nom_usine , min (id) as id from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text and failed is true
group by nom_usine) as k
where lb.code_commune_insee  = uc.code_insee::text and failed is true
and lb.id = k.id and k.nom_usine=uc.nom_usine ;

select nom_usine , min (id) from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text and failed is true
group by nom_usine
--order by uc.nom_usine , code_insee;

update theses.usine_complet uc set lat = q.lat::float, long =q.long::float
from (
select uc.nom_usine , lb.coordonnees_gps , 
substring(coordonnees_gps,  4 , strpos( coordonnees_gps, ',')-4) as lat, 
substring(coordonnees_gps,  strpos( coordonnees_gps, ',')+1, strpos(coordonnees_gps,')')-strpos( coordonnees_gps, ',')-1) as long
from theses.usine_complet uc, laposte_base lb,
(select nom_usine , min (id) as id from theses.usine_complet uc, laposte_base lb
where lb.code_commune_insee  = uc.code_insee::text and failed is true
group by nom_usine) as k
where lb.code_commune_insee  = uc.code_insee::text and failed is true
and lb.id = k.id and k.nom_usine=uc.nom_usine ) as q 
where q.nom_usine = uc.nom_usine ;
-- mise à jour  à la fuck

select * from theses.usine_complet uc ;






"""