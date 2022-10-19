# -*- coding: utf-8 -*-
"""
Created on Wed Oct 19 10:51:39 2022
Do the mapping of French ports of Portic
@author: cplume01
"""

import pandas as pd
import requests
import folium
url_to_read = "http://data.portic.fr/api/ports?param=&shortenfields=false&both_to=false&date=1787"

resp = requests.get(url_to_read) #Récuperer les données
df = pd.DataFrame(resp.json()) 

#print(df.groupby(['admiralty']).count())

#print(df.groupby((['shiparea'])).count())

####################### Sol Benjamin

m = folium.Map(location=[46.34015, 2.60254], zoom_start=6, tiles="Stamen Terrain")
#filter
subset=df[df['state_1789_fr']=='France']
subset.reset_index(drop=True, inplace=True)

a=subset.toponym
b=subset.x
c=subset.y

for i in range(len((subset.toponym))):
    folium.Marker(
        location=[c[i], b[i]],
        popup=a[i],
        icon=folium.Icon(icon="Waypoint"),
    ).add_to(m)



m.save("index.html")

####################### Sol Guilhem
#Filtre

longitudes = np.array(df.loc[df['state_1789_fr'] == 'France']['x'])
latitudes = np.array(df.loc[df['state_1789_fr'] == 'France']['y'])
names = np.array(df.loc[df['state_1789_fr'] == 'France']['toponym'])

# Code carte

m = folium.Map(location=[49.49437, 0.107929], zoom_start=3,tiles="Stamen Terrain")


for i in range(len(latitudes)):
    folium.CircleMarker(
    location=[latitudes[i], longitudes[i]],
    radius=5,
    popup=names[i],
    color="#3186cc",
    fill=True,
    fill_color="#3186cc",
).add_to(m)

m

####################### Sol Nushrat

m = folium.Map(location=[46.156089, -1.156176],tiles="Stamen Watercolor")
m.add_child(folium.LatLngPopup())
m.add_child(folium.ClickForMarker(popup="Waypoint"))

for x,y,name,state,adm in zip(df.x,df.y,df.toponyme_standard_fr,df.state_1789_fr,df.admiralty):
    if state=='France':
        folium.Marker([y, x], popup=f"<i>{adm}</i>", tooltip=name,icon=folium.Icon(color="green")).add_to(m)
    else:
        folium.Marker([y, x], popup=f"<i>{adm}</i>", tooltip=name).add_to(m)
m



