#!/usr/bin/python3
# -*-coding:UTF-8 -*
'''
Created on 07 november 2024
@author: Christine PLUMEJEAUD-PERREAU, U.M.R 7301 MIGRINTER
Master 2 course : Environnemental data to information

TP for using HTML forms to build figures with user choices
Used to read and parse data coming from the data.portic.fr API
Then it builds a viz using BOKEH and sends the figure in the template HTML
with also a map (folium) and another form to change the state 
The figure is changing according to user choices (name of the admiralty) using Ajax

Works with portic_map_stateform_ajax2.html and update_map.html and update_figure.html
'''

from flask import Flask, render_template, request, jsonify
app = Flask(__name__)
import folium
from folium.plugins import MarkerCluster
import requests
import pandas as pd

import json
import requests
import math

from bokeh.embed import components
from bokeh.plotting import figure, show
from bokeh.resources import INLINE
from bokeh.models import ColumnDataSource
from bokeh.palettes import Spectral6
from bokeh.palettes import Viridis
from bokeh.transform import factor_cmap
import bokeh.palettes as bp

global ports 

@app.route('/')
def index():
    return 'Hello, World!'

def get_data(local = False) : 
    #try to execute this function only once
    print("getting data from server")
    if not local:
        url = "http://data.portic.fr/api/ports/?shortenfields=false&both_to=false&date=1787"
        r = requests.get(url)
        data = r.json()
    else : 
        ## If you read data in a file on your server
        filename = "C:/Travail/Enseignement/Cours_M2_python/2023/code/resultats/export3_port_geojson.geojson"
        output = open(filename, "r")
        data = json.load(output)
            
    #Convert representation of data : from json to dataframe 
    df = pd.DataFrame(data)
    
    # Dealing with null values
    # df.admiralty.isnull().values.any() #True 
    #values = {'admiralty': 'X', 'state_1789_fr' : 'UNKNOWN'}
    values = {'state_1789_fr' : 'UNKNOWN'}
    df = df.fillna(value=values)
    #df.admiralty.isnull().values.any() #False 
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
    
    bounds = [[ports_filt['y'].min(), ports_filt['x'].min()], [ports_filt['y'].max(), ports_filt['x'].max()]]
    m.fit_bounds(bounds)
    return m

def create_state_listoptions(ports):
    ports = ports[ports.state_1789_fr.notnull()  ] 
    list_toselect = (ports.state_1789_fr).unique()
    
    liste_options = list()
    option_str = '<option value="%s">%s</option>'
    #<option value="France">France</option>
    for items in list_toselect:
        test = option_str %(items, items)
        #print(test)
        liste_options.append(test)
    return liste_options

def create_amirautes_listoptions(ports):
    ports = ports[ports.state_1789_fr.notnull()] 
    list_toselect = (ports.admiralty).unique()
    
    liste_options = list()
    option_str = '<option value="%s">%s</option>'
    for items in list_toselect:
        test = option_str %(items, items)
        liste_options.append(test)
    return liste_options
    
def build_fig3(df):
    '''
    Bar chart : Pour toutes les amirautés, nombre de ports différents, en couleur différente par nom d'amirauté
    '''
    test = df.groupby('admiralty')['ogc_fid'].count()
    fruits = [i for i in test.index]
    counts = [i for i in test.values]
    
    #fruits = df.groupby('admiralty').count()['admiralty']
    #counts = df.groupby('admiralty')['ogc_fid'].count()
    
    source = ColumnDataSource(data=dict(titi=fruits, toto=counts))
    
    # init a  bar chart:
    # https://docs.bokeh.org/en/latest/docs/user_guide/basic/bars.html 
    
    p = figure(x_range=fruits, height=700,width=1200, title="Number of ports per admiralties in 1787")
    p.xaxis.major_label_orientation = math.pi/2
    p.vbar(x='titi', 
           top='toto', 
           width=0.9, 
           source=source,
           line_color='white', 
           fill_color=factor_cmap('titi', palette=bp.turbo(len(fruits)), factors=fruits))
    
    p.xgrid.grid_line_color = None
    p.y_range.start = 0
    p.y_range.end = max(counts)*1.2
    return p

def build_fig4(ports, filterAdmiralty):
    '''
    Bar chart : nombre de citations (volume du traffic entrant ou sortant) de chaque port contenus dans l'amirauté sélectionnée
    '''
    df = ports
    
    ## filter the dataset to keep only ports of the given admiralty
    if (filterAdmiralty=='Unknown') :
        df = df[df.admiralty.isnull() ]
    else :
        df = df[df.admiralty.eq(filterAdmiralty) ]
    print(df.shape)
            
    source = ColumnDataSource(data=dict(names=df['toponyme_standard_fr'], counts=df['total']))

    # init a  bar chart:
    # https://docs.bokeh.org/en/latest/docs/user_guide/basic/bars.html 
    mytitle = "Counts of toponyms citation for ports of %s in 1787"% filterAdmiralty
    p = figure(x_range=df['toponyme_standard_fr'], width=800, height=600, title=mytitle)

    p.vbar(x='names', 
        top='counts', 
        width=0.9, 
        source=source,
       line_color='white', 
       fill_color='navy')
    p.xgrid.grid_line_color = None
    p.y_range.start = 0
    p.y_range.end = max(df['total'])*1.2
    p.xaxis.major_label_orientation = math.pi/2
    
    return p

def build_viz_withparam(df, filterAdmiralty=None):
    #print(filterAdmiralty)
    if (filterAdmiralty is not None) :
        return build_fig4(ports, filterAdmiralty)
    else :
        return build_fig3(ports)


    
@app.route('/map_template_form')
def toto():
    country = request.args.get("pays")
    print("parametre lu")
    print(country)
    ports_filt = ports
    if country != None:
        # Filtrer le dataframe sur le pays
        ports_filt = ports[ports.state_1789_fr == country]
        
    liste_options = create_state_listoptions(ports)
    m = create_amap(country)
    
    
    amirautes = create_amirautes_listoptions(ports)
    #print(amirautes)
    
    fig = build_viz_withparam(ports)
    #show(fig)

    # grab the static resources
    js_resources = INLINE.render_js()
    css_resources = INLINE.render_css()

    # render template
    script, div = components(fig)   
    
    return render_template('portic_map_stateform_ajax2.html', 
                           msg=m.get_root()._repr_html_(), 
                           opt = ' '.join(liste_options), 
                           y = ports_filt.to_html(),
                           plot_script=script,
                            plot_div=div,
                            liste_amirautes = ' '.join(amirautes),
                            js_resources=js_resources,
                            css_resources=css_resources)

@app.route('/updatemap', methods=['GET','POST'])
def update_map_ajax():
    country = request.args.get("pays")
    print("parametre lu")
    print(country)
    ports_filt = ports
    if country != None:
        # Filtrer le dataframe sur le pays
        ports_filt = ports[ports.state_1789_fr == country]
        
    liste_options = create_state_listoptions(ports)
    m = create_amap(country)
    
    # pass the msg (the map) to render_template    
    return jsonify(
        html_plot=render_template('update_map.html', msg=m.get_root()._repr_html_())
    )


@app.route('/update_graphic', methods=['GET','POST'])
def update_graphic_map():
    #Parse the param
    param = request.args.get("admiralty")
    
    #Appeler la redéfinition du graphique avec ce paramètre
    fig = build_viz_withparam(ports, param)
    
    # render template
    script, div = components(fig)

    # pass the div and script to render_template    
    return jsonify(
        html_plot=render_template('update_figure.html', plot_script=script, plot_div=div)
    )
    
if __name__ == '__main__':
    ports = get_data(True) #Executed when for server init, never after
    app.run(debug=True, port=5054)

