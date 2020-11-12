from flask import Flask, render_template, request, jsonify

import pandas as pd
import numpy as np


from bokeh.embed import components
from bokeh.resources import INLINE

from bokeh.plotting import figure, output_file, show, output_notebook
from bokeh.tile_providers import CARTODBPOSITRON, get_provider  
from bokeh.models.mappers import CategoricalColorMapper

from bokeh.models import ColumnDataSource, HoverTool
from bokeh.palettes import GnBu, PiYG11,Set3, Category20, Category20c
from bokeh.transform import linear_cmap, factor_cmap

import pandas.io.sql as sql
from sqlalchemy import create_engine


app = Flask(__name__)


           
def getArtox_data_for_analyses() :
    '''
    you read the database and get data for analyses
    return a dataframe
    '''
    engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')

    # write a query that retrieve the lines of birds trajectory in 3857 EPSG
    query = """
            select bird_id, sex, x_path_coordinates, y_path_coordinates , clean_glsid, migration_length
            from arctic.data_for_analyses where bird_path is not null 
        """

    # run the query and save the result in a df variable 
    df = sql.read_sql_query(query, engine)
           
    return df

def getArtox_gps_data() :
    '''
    you read the database and get gps data
    return a dataframe
    '''
    engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')

    query = """ select id, timestampgps, st_x(point3857) as x, st_y(point3857) as y from arctic.kap_hoegh_gls """
    gps = sql.read_sql_query(query, engine)
    
    return gps

def build_viz_withparam(df, filterBird='LIAK11EG12'):
    #print(filterState)
    gps = getArtox_gps_data()
    
    ## filter the dataset to keep only ports of the given state
    if (filterBird!='LIAK11EG12') :
        if (filterBird=='Unknown') :
            df = df[df.bird_id.isnull() ]
        else :
            df = df[df.bird_id.eq(filterBird) ]
    
    ## Build the map
    p = figure(x_range=(-9587947, 1113194), y_range=(3503549, 13195489),
               x_axis_type="mercator", y_axis_type="mercator")

    tile_provider = get_provider(CARTODBPOSITRON)
    p.add_tile(tile_provider)

    msource = ColumnDataSource(df)
    # https://docs.bokeh.org/en/latest/docs/reference/palettes.html
    color_mapper = CategoricalColorMapper(palette=["blue", "pink"], factors=["M", "F"])

    ## Filter GPS data with the choosen bird
    gpsnumber = df.loc[df['bird_id']==filterBird, 'clean_glsid'].values[0]
    gpsnumber #'148'
    msourceGPS = ColumnDataSource(gps.loc[gps['id']==gpsnumber,])

    #process the time dimension
    thisbirdtimes = gps.loc[gps['id']==gpsnumber, 'timestampgps'].values
    thisbirdtimes = pd.to_datetime(thisbirdtimes) #transform string into datetime type

    #First solution for points color : time on a continuous scale
    t = np.array([xi.timestamp()  for xi in thisbirdtimes])  #transform datetime into float type
    msourceGPS.add(t, 'timeasreal')
    point_mapper = linear_cmap(field_name='timeasreal', palette=GnBu[9], low=min(t), high=max(t))
    #OK for time on a continuous scale, you can also use the palette PiYG11

    ## Afficher les coordonnées GPS de cet oiseau
    #https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.loc.html

    #p.line(df.iloc[3, 2], df.iloc[3, 3], color='red', line_width=2)
    p.line(df.loc[df['bird_id']==filterBird, 'x_path_coordinates'].values[0], 
            df.loc[df['bird_id']==filterBird, 'y_path_coordinates'].values[0], 
            color='red', 
            line_width=1)

    p.circle(x='x', y='y', size=7, source=msourceGPS, fill_color=point_mapper, fill_alpha=1, line_alpha=0)

    return p


@app.route('/')
def index():
    """
    Initial plot 
    """
    df = getArtox_data_for_analyses()
    fig = build_viz_withparam(df)

    # grab the static resources
    js_resources = INLINE.render_js()
    #print(js_resources)
    css_resources = INLINE.render_css()

    # render template
    script, div = components(fig)

    tab = df[['bird_id', 'sex', 'migration_length']]
    content = tab.to_html()

    html = render_template(
        'arctox_map.html',
        plot_script=script,
        plot_div=div,
        table_div = content,
        js_resources=js_resources,
        css_resources=css_resources,
    )

    return html

@app.route('/ajaxviz', methods=['GET','POST'])
def viz_ajax():
    df = getArtox_data_for_analyses()
    #Parse the param
    bird = request.args.get("bird")
    if (bird is not None and len(bird)>0) :
        fig = build_viz_withparam(df, bird)
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