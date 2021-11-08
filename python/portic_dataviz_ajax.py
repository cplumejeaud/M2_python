#!/usr/bin/python3
# -*-coding:UTF-8 -*
'''
Created on 12 october 2020
@author: Christine PLUMEJEAUD-PERREAU, U.M.R 7266 LIENSs
Master 2 course : Web programming with python

TP for using HTML forms to build figures with user choices
Used to read and parse data coming from the data.portic.fr API
Then it builds a viz using BOKEH and sends the figure in the template HTML
The figure is changing according to user choices (name of the state)
using Ajax

'''
from flask import Flask, render_template, request, jsonify

import http.client
from io import StringIO, BytesIO, TextIOWrapper
import json
import pandas as pd

from bokeh.embed import components
from bokeh.plotting import figure
from bokeh.resources import INLINE
from bokeh.models import ColumnDataSource
from bokeh.palettes import Spectral6
from bokeh.palettes import Viridis
from bokeh.transform import factor_cmap


app = Flask(__name__)

def getStateForDate(jsonelement, dateparam):
    """
    jsonelement : [{"1749-1815" : "Toscane"},{"1801-1807" : "Royaume d'Étrurie"},{"1808-1814" : "Empire français"}]
    Internal method to output state for 1787 as dateparam
    return name of the state of the period including dateparam 
    state = getStateForDate(json.load(StringIO('[{"1749-1815" : "Toscane"},{"1801-1807" : "Royaume d'Étrurie"},{"1808-1814" : "Empire français"}]')), 1787)
    """
    eltjson = json.loads(jsonelement) 
    for k in eltjson :
        for dates, state in k.items():
            datesarray = dates.split('-')
            start = datesarray[0]
            end = datesarray[1]
            if (int(start) <= dateparam <= int(end)):
                return state
            


def getPorticData(local = False) :
    '''
    you grab data from another Web server
    https://docs.python.org/3.7/library/http.client.html#httpresponse-objects
    #target_url = "http://data.portic.fr/api/ports/?shortenfields=false&both_to=false&date=1787"
    return a dataframe
    '''
    if not local:
        conn = http.client.HTTPConnection("data.portic.fr")
        conn.request("GET", "/api/ports/?shortenfields=false&both_to=false&date=1787")
        r1 = conn.getresponse()
        data1 = r1.read()  # This will return entire content.
        b = BytesIO(data1)
        b.seek(0) #Start of stream (the default).  pos should be  = 0;
        data = json.load(b)
    else : 
        ## If you read data in a file on your server
        with open('ports.json', encoding="utf-8") as f:
            data = json.load(f)

    ## Create a dataframe out of json
    df = pd.DataFrame(data)
    
    # Dealing with null values
    df.admiralty.isnull().values.any() #True 
    values = {'admiralty': 'X'}
    df = df.fillna(value=values)
    df.admiralty.isnull().values.any() #False 

    #https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html
    for elt in df['belonging_states'].unique():
        if elt is None :
            df.loc[df.belonging_states.eq(elt), 'state_1787'] = 'X' 
        else :
            state = getStateForDate(elt, 1787)
            if state is not None:
                df.loc[df.belonging_states.eq(elt), 'state_1787'] = state
           
    return df



def build_viz_withparam(df, filterState='the World'):
    #print(filterState)

    ## filter the dataset to keep only ports of the given state
    if (filterState!='the World') :
        if (filterState=='Unknown') :
            df = df[df.state_1787.isnull() ]
        else :
            df = df[df.state_1787.eq(filterState) ]

    source = ColumnDataSource(data=dict(names=df['toponym'], counts=df['total']))

    # init a basic bar chart:
    # http://bokeh.pydata.org/en/latest/docs/user_guide/plotting.html#bars
    mytitle = "Counts of toponyms citation for ports of %s in 1787"% (filterState)
    p = figure(x_range=df['toponym'], plot_width=800, plot_height=600, title=mytitle)

    number_of_toponyms = 3
    if len(df['toponym']) > 3:
        number_of_toponyms = len(df['toponym'])
    p.vbar(x='names', top='counts', width=0.9, source=source, legend_field="names",
       line_color='white', fill_color=factor_cmap('names', palette=Viridis[11], factors=df['toponym']))

    p.xgrid.grid_line_color = None
    p.y_range.start = 0
    p.y_range.end = max(df['total'])*1.2
    p.legend.orientation = "vertical"
    p.legend.location = "top_center"

    return p


@app.route('/')
def index():
    """
    Initial plot 
    """
    df = getPorticData(local = False)
    fig = build_viz_withparam(df)

    # grab the static resources
    js_resources = INLINE.render_js()
    #print(js_resources)
    css_resources = INLINE.render_css()

    # render template
    script, div = components(fig)

    html = render_template(
        'ajax.html',
        plot_script=script,
        plot_div=div,
        js_resources=js_resources,
        css_resources=css_resources,
    )

    return html

@app.route('/ajaxviz', methods=['GET','POST'])
def viz_ajax():
    df = getPorticData(local = True)
    #Parse the param
    state = request.args.get("state")
    if (state is not None and len(state)>0) :
        fig = build_viz_withparam(df, state)
    else:
        fig = build_viz_withparam(df)

    # render template
    script, div = components(fig)

    # pass the div and script to render_template    
    return jsonify(
        html_plot=render_template('update_figure.html', plot_script=script, plot_div=div)
    )



if __name__ == '__main__':
    app.run(debug=True, port=5050)

