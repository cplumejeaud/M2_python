from flask import Flask, render_template, request
app = Flask(__name__)
import folium
from folium.plugins import MarkerCluster
import requests
import pandas as pd

global ports 

@app.route('/')
def index():
    return 'Hello, World!'

def get_data() : 
    #try to execute this function only once
    print("getting data from server")
    url = "http://data.portic.fr/api/ports/?shortenfields=false&both_to=false&date=1787"
    r = requests.get(url)
    data = r.json()
    #Convert representation of data : from json to dataframe 
    df = pd.DataFrame(data)
    return df

def create_amap(param):
    ports_filt = ports
    if param != None:
        # Filtrer le dataframe sur le pays
        ports_filt = ports[ports.state_1789_fr == param]
    
    # Centrer sur 49.49437, 0.107929
    m = folium.Map(location=(49.49437, 0.107929), zoom_start=4, tiles="cartodb positron", width=1200, height=800)

    ## add markers for chef-lieux 
    group_1 = folium.FeatureGroup("ports").add_to(m)

    popup_content = '<table><tr><td>Nom</td><td>{0}</td></tr><tr><td>Statut</td><td>{1}</td></tr><tr><td>Amirauté</td><td>{2}</td></tr><tr><td>Pays 1789</td><td>{3}</td></tr></table>'

    for index, row in ports_filt.iterrows() :
        #position des markers  : [latitude, longitude]
        folium.Marker(
            location=[row.y, row.x], 
            tooltip=row.toponyme_standard_fr,
            popup=popup_content.format(row.toponyme_standard_fr, row.status, row.admiralty, row.state_1789_fr),
            icon=folium.Icon(color="green"),
        ).add_to(group_1)
        
    folium.LayerControl().add_to(m)
    return m


@app.route('/map_template')
def toto():
    country = request.args.get("pays")
    print("parametre lu")
    print(country)
    if country != None:
        # Filtrer le dataframe sur le pays
        ports_filt = ports[ports.state_1789_fr == country]
    
    m = create_amap(country)
    return render_template('portic_map.html', msg=m.get_root()._repr_html_(), y = ports_filt.to_html())


if __name__ == '__main__':
    ports = get_data() #Executed when for server init, never after
    app.run(debug=True, port=5050)

