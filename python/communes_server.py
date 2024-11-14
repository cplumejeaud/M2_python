from flask import Flask, render_template, request, jsonify
app = Flask(__name__)
import folium
from folium.plugins import MarkerCluster
import requests
import pandas as pd

import pandas.io.sql as sql
from sqlalchemy import create_engine, text 
import geopandas
import branca
import folium 
global mesdata 

@app.route('/')
def index():
    return 'Hello, World!'

def get_data() : 
    #try to execute this function only once
    print("getting data from server")
    query = text(""" select g.insee_com, g.nom, "DENS", case when ("MED21"='s') then null else "MED21"::int end,
                
                t5."P21_CHOM1564",t5."P21_CHOM1524",

    "P21_POP0014"/"P21_POP"*100 as POP15,"P21_POP1529"/"P21_POP"*100 as POP1530,

    ("P21_POP3044"+"P21_POP4559")/"P21_POP"*100 as POP3060,"P21_POP6074"/"P21_POP"*100 as POP6075,("P21_POP7589"+"P21_POP90P")/"P21_POP"*100 as POP75P,

    g.geom 
    from geocom g, grille gd, table07 t7 ,table05 t5, table00 t0

    where insee_reg ='75'

    and gd."CODGEO" = insee_com and t7."CODGEO"= g.insee_com

    and t5."CODGEO"= g.insee_com and t0."CODGEO"= g.insee_com; """) 

    con = create_engine('postgresql://postgres:postgres@localhost:5432/communes').connect()
    mesdata = geopandas.GeoDataFrame.from_postgis(query, con)  
    return mesdata

def create_amap(paramvar):

    style_tooltip_txt = """
                background-color: #F0EFEF;
                border: 2px solid black;
                border-radius: 3px;
                box-shadow: 3px;
            """
            
    #https://colorbrewer2.org/#type=diverging&scheme=Spectral&n=6
    colormap = branca.colormap.StepColormap(
        vmin=mesdata[paramvar].quantile(0.0),
        vmax=mesdata[paramvar].quantile(1),
        colors=['#4a1486', '#1d91c0','#7fcdbb','#fee08b','#fc8d59', '#d53e4f', '#b2182b'],
        index=[ mesdata[paramvar].quantile(0.10),mesdata[paramvar].quantile(0.30), mesdata[paramvar].quantile(0.50), mesdata[paramvar].quantile(0.70), mesdata[paramvar].quantile(0.90), mesdata[paramvar].quantile(0.95)],
        caption="Médiane du niveau de vie (€)"
    )

    ##Minimap
    from folium.plugins import MiniMap


    m = folium.Map(location=(45.00, 0.15605), zoom_start=8, tiles="cartodb positron", width=1000, height=1200) #45.64844

    

    ## Bulles avec les infos numériques sur les communes
    tooltip = folium.GeoJsonTooltip(
        fields=["nom", "DENS", paramvar],
        aliases=["commune:", "Niveau d'urbanité:", "variable:"],
        localize=True,
        sticky=False,
        labels=True,
        style=style_tooltip_txt,
        max_width=800,
    )
    

    group_3 = folium.FeatureGroup("communes").add_to(m)
    ## Les communes, année 1962
    g = folium.GeoJson(
        mesdata,
        style_function=lambda x: {
            "fillColor": colormap(x["properties"][paramvar]) if x["properties"][paramvar] is not None else "transparent", 
            "color": "black", 
            "fillOpacity": 1,
                "weight": 0.5,
                "opacity": 0.65
        },
        tooltip=tooltip
    ).add_to(group_3)
    colormap.add_to(m)

    MiniMap().add_to(m)
    folium.LayerControl().add_to(m)
    return m

def create_state_listoptions(ports):
    query2 = text("""select "COD_VAR", "LIB_VAR_LONG" 
    from dico_var dv 
    where "COD_VAR" in ('MED21','P21_CHOM1564', 'P21_CHOM1524');""")

    con = create_engine('postgresql://postgres:postgres@localhost:5432/communes').connect()
    dico = pd.read_sql(query2, con)  
    dico = dico.set_index('COD_VAR')['LIB_VAR_LONG'].to_dict()
    dico['pop15'] = 'Part de personnes âgées de 0 à 14 ans'
    dico['pop1530'] = 'Part de personnes âgées de 15 à 29 ans'
    dico['pop3060'] = 'Part de personnes âgées de 30 à 59 ans'
    dico['pop6075'] = 'Part de personnes âgées de 60 à 74 ans'
    dico['pop75p'] = 'Part de personnes âgées de plus de 75 ans'
    
   
    liste_options = list()
    option_str = '<option value="%s">%s</option>'
    #<option value="France">France</option>
    for items in dico.keys():
        test = option_str %(items, dico[items])
        print(test)
        liste_options.append(test)
    return liste_options
        
@app.route('/map_template_form')
def toto():
    country = request.args.get("variable")
    print("parametre lu")
    print(country)
           
    liste_options = create_state_listoptions(mesdata)
    if country is None : 
        country = 'MED21'
    m = create_amap(country)
    return render_template('NA_map_form_ajax.html', msg=m.get_root()._repr_html_(), opt = ' '.join(liste_options))

@app.route('/updatemap', methods=['GET','POST'])
def viz_ajax():
    country = request.args.get("variable")
    print("parametre lu")
    print(country)
    
    liste_options = create_state_listoptions(mesdata)
    m = create_amap(country)
    
    # pass the div and script to render_template    
    return jsonify(
        html_plot=render_template('update_map.html', msg=m.get_root()._repr_html_())
    )


if __name__ == '__main__':
    mesdata = get_data() #Executed when for server init, never after
    mesdata.crs = 2154
    mesdata = mesdata.to_crs("EPSG:4326")
    app.run(debug=True, port=5054)

