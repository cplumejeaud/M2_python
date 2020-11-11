# https://docs.bokeh.org/en/latest/docs/user_guide/geo.html
from bokeh.plotting import figure, output_file, show, output_notebook
from bokeh.tile_providers import CARTODBPOSITRON, get_provider  
from bokeh.models.mappers import CategoricalColorMapper

from bokeh.models import ColumnDataSource, HoverTool
from bokeh.palettes import GnBu, PiYG11,Set3, Category20, Category20c
from bokeh.transform import linear_cmap, factor_cmap

import pandas.io.sql as sql
from sqlalchemy import create_engine
import numpy as np
import pandas as pd


## Extract the data from sql database
## Open an ssh tunnel in Windows cmd line or Mac Terminal
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 
## Change here with the correct user, password 
## Open the connection
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')
#engine = create_engine('postgresql://maliha:malihaM2@localhost:5432/savoie')

# write a query that retrieve the lines of birds trajectory in 3857 EPSG
query = """
        select bird_id, sex, x_path_coordinates, y_path_coordinates , clean_glsid
        from arctic.data_for_analyses where bird_path is not null 
    """

# run the query and save the result in a df variable 
df = sql.read_sql_query(query, engine)

df.columns
#Index(['bird_id', 'sex', 'x_path_coordinates', 'y_path_coordinates', 'clean_glsid'], dtype='object')


query = """ select id, timestampgps, st_x(point3857) as x, st_y(point3857) as y from arctic.kap_hoegh_gls """
gps = sql.read_sql_query(query, engine)

# Read local GPS data IF YOU DON'T HAVE DATABASE ACCESS
#gps = pd.read_csv("C:\Travail\CNRS_mycore\Cours\Cours_M2_python\Projet_Arctox\gps2.csv", sep=';')
print(gps.columns)


'''
Index(['id', 'sex', 'dategps', 'timegps', 'timestampgps', 'lat', 'long',
       'pointgps', 'distance_to_colony', 'week', 'clean_lat', 'pkid',
       'smooth_lat', 'clean_long', 'smooth_long', 'point3857', 'x', 'y'],
      dtype='object')
'''

## Do the map

output_file("arctox_map3.html")
#output_notebook()


# Ranges matches this bbox in long/lat (-86.13, 30) (10, 75.6)
# select st_setsrid(st_transform(st_setsrid(st_makebox2d(st_point(-86.13, 30),  st_point(10, 75.6)), 4326), 3857), 3857)

# expected an element of either String or List(Tuple(String, String))
# range bounds supplied in Web mercator coordinates
p = figure(x_range=(-9587947, 1113194), y_range=(3503549, 13195489),
           x_axis_type="mercator", y_axis_type="mercator")

tile_provider = get_provider(CARTODBPOSITRON)
p.add_tile(tile_provider)

msource = ColumnDataSource(df)
# https://docs.bokeh.org/en/latest/docs/reference/palettes.html
color_mapper = CategoricalColorMapper(palette=["blue", "pink"], factors=["M", "F"])

## Filter GPS data with the choosen bird
gpsnumber = df.loc[df['bird_id']=='LIAK11EG12', 'clean_glsid'].values[0]
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

#Second solution for points color : time as factor 
#be aware : you give unique values of factors, as string, and sorted if the category has an order
#1. you sort month (np.sort)
#2. you select distinct values (np.unique)
#3. you cast in string : .astype(str)
msourceGPS.add(thisbirdtimes.month.astype(str), 'timeasfactor') #get month from datetime and transform into string type
point_mapper2 = factor_cmap(field_name='timeasfactor', palette=Category20c[12], factors=np.unique(np.sort(pd.to_datetime(thisbirdtimes).month)).astype(str))
#OK for time as factor (using months) : you can also use the palette Set3[12] 



## Afficher les coordonnées GPS de cet oiseau
#https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.loc.html

#p.line(df.iloc[3, 2], df.iloc[3, 3], color='red', line_width=2)
p.line(df.loc[df['bird_id']=='LIAK11EG12', 'x_path_coordinates'].values[0], 
        df.loc[df['bird_id']=='LIAK11EG12', 'y_path_coordinates'].values[0], 
        color='red', 
        line_width=1)



#p.circle(x=gps.loc[gps['id']==gpsnumber, 'x'].values, y=gps.loc[gps['id']==gpsnumber, 'y'].values, 
#size=5, fill_color="blue", fill_alpha=0.8)

p.circle(x='x', y='y', size=7, source=msourceGPS, fill_color=point_mapper, fill_alpha=1, line_alpha=0)

#print(df.loc[df['bird_id']=='LIAK11EG12', 'x_path_coordinates'].values[0])
#print (df.iloc[3, 2])
#print (df.iloc[3, 0])

show(p)

