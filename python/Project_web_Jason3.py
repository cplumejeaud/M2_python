# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 13:34:49 2022

@author: Nushrat Yeasmin, 
with the help of Christine Plumejeaud, 
Chicot	Guilhem
Seksaf	Wassim
Galliot	Benjamin

"""
import numpy as np
import pandas as pd 
from dash import Dash, dcc, html
import dash_bootstrap_components as dbc

import plotly.express as px
import plotly.graph_objects as go
from dash.dependencies import Input, Output, State
from dash.exceptions import PreventUpdate
import pandas.io.sql as sql
from sqlalchemy import create_engine


app = Dash(
    external_stylesheets=[dbc.themes.BOOTSTRAP]
)

_last_long = 0
_last_lat = 0

def request_and_save(trackid):
    #Create a query to seek after the data
    engine = create_engine('postgresql://postgres:xxxx@localhost:8007/jason3')
    # write a query that retrieve the x and y positions of points in 3857 EPSG
    query = """select longitude,latitude,time,altitude from trackdata where trackid  = '""" +trackid+"'"
    
    df = sql.read_sql_query(query, engine)
    
    return df

df = request_and_save(r'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627')


#app = Dash(__name__)

def buildFigure1(df): 
    
    i=len(df.index)-1
    
    # Figure to show variable variation along latitude : la courbe
    fig_lat1 = px.line(df, x="latitude", y="altitude", title='Altitude')
    fig_lat2 = px.scatter(x=[df.latitude[i]],y=[df.altitude[i]],title='Point', color_discrete_sequence=['red'])
    fig_lat = go.Figure(data=fig_lat1.data + fig_lat2.data)
    return fig_lat

def buildFigure2(df): 
    # Figure to show the track on map
    
    fig_track = px.scatter_mapbox(df, lat="latitude", lon="longitude",color="altitude",
                      color_continuous_scale=px.colors.cyclical.IceFire, size_max=15, zoom=1)
    
    #fig_track.add_scattergeo(lon=[0], lat=[0], mode = 'text', text = "HELLO !! ")
    fig_track.add_trace(go.Scattermapbox(mode='markers', lon = [_last_long], lat=[_last_lat], marker = {'size':20}))
    
    
    fig_track.update_layout(mapbox_style="stamen-terrain", mapbox_zoom=1, mapbox_center_lat = 1,
        margin={"r":0,"t":0,"l":0,"b":0})
    
    #fig_track.add_scattergeo(lon=(df.longitude[i]), lat=(df.latitude[i]))
    
    
    #fig_map = go.Figure(data=fig_track.data )
    return fig_track

def setForms(df) : 
    sliderHorizontal = dcc.Slider(
        min=np.nanmin(df.longitude),
        max=np.nanmax(df.longitude),
        id = 'longitude_slider'
    )
    
    sliderVertical = dcc.Slider(
        min=np.nanmin(df.latitude),
        max=np.nanmax(df.latitude),
        id = 'latitude_slider',
        vertical=True,
    )
    
    themap = dcc.Graph(
        id='track-in-map',
        figure=buildFigure2(df)        
        
    )
    
    courbe = dcc.Graph(
        id='variable-in-lat',
        figure=buildFigure1(df)
    )
    return sliderHorizontal, sliderVertical, themap, courbe

def defineLayout(themap, courbe, sliderHorizontal, sliderVertical) : 

    #Définition des sliders et de la carte dans un tableau
    styleTD={'width':'10%'}
    
    row1 = html.Tr([html.Td("Empty", style=styleTD), html.Td(sliderHorizontal)])
    row2 = html.Tr([html.Td(sliderVertical, style=styleTD), html.Td(themap)])
    table_body = [html.Tbody([row1, row2])]
    table = dbc.Table(table_body, bordered=True)
    
    # Mise en page générale
    row = html.Div(
        [
            dbc.Row(dbc.Col(html.Div("Mon titre à venir"), align='center', style={'align':'center'})),
    
            dbc.Row(
                [
                    dbc.Col(html.Div("La colonne des variables"), width=2),
                    dbc.Col(html.Div(table), width=10),
                    #dbc.Col(html.Div("One of three columns"), width=3),
                ]
            ),
            
            dbc.Row(
                [
                    dbc.Col(html.Div(""), width=2),
                    dbc.Col(html.Div(courbe), width=10),
                ]
            ),
        ]
    )
    return row




fig_track = buildFigure2(df)
fig_lat = buildFigure1(df)
sliderHorizontal, sliderVertical, themap, courbe = setForms(df) 
app.layout = defineLayout(themap, courbe, sliderHorizontal, sliderVertical)


@app.callback(
    #Output('variable-in-lat', 'figure'),
    Output('track-in-map', 'figure'),
    Input('latitude_slider', 'value'), 
    Input('longitude_slider', 'value')
)
#    Input('longitude_slider', 'value')


def update_graph(latitude_slider, longitude_slider):
    #, longitude_slider
    minlat = np.nanmin(df.latitude)
    minlong = np.nanmin(df.longitude)

    if latitude_slider is None and longitude_slider is None:
        raise PreventUpdate
    else:
        
        if longitude_slider is not None :
            print('long is ' + str(longitude_slider))
            idx_long = int(np.argmin(abs(df.longitude-longitude_slider)))
            if latitude_slider is None:
                idx_lat = int(np.argmin(abs(df.latitude-minlat)))
            
        if latitude_slider is not None :
            print('lat is ' + str(latitude_slider))
            idx_lat = int(np.argmin(abs(df.latitude-latitude_slider)))
            if longitude_slider is None:
                idx_long = int(np.argmin(abs(df.longitude-minlong)))
           
            
        #m = fig_track.select_traces({'type':'Scattermapbox'})
        #print('traces is' + str(m))
        #print(m.__getattribute__('lon'))
            
        fig_track.add_trace(go.Scattermapbox(mode='markers', lon = [df.longitude[idx_long]], lat=[df.latitude[idx_lat]], marker = {'size':20}))
    
    
        #fig_map = go.Figure(data=fig_track.data )

    return fig_track

app.run_server(debug=True, use_reloader=False)
