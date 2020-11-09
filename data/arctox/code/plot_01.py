# -*- coding: utf-8 -*-
'''
Created on 21 october 2020
@author: cplumejeaud
Master 2 La Rochelle University - Geographic information
This requires the arctox database
In the exemple : it is in the savoie database, in the schema arctic

Here is the job of this TP : 
- clean the gps_id in the data_for_analyses using SQL
- make a join with the bird path 
- compute the total length of the path
- remove/clean abnormal values : 
- connect through a python program to database
- see them : make a bokeh map, make a bokeh plot
- replace the bad latitude values with clever values using python / SQL
- redo the job of computing points and paths of birds using python / SQL 
- analyse the correlation between (Wing / Weight) and length of path : do the big and healthy birds go further than little ones ? 
- You can do it using R connected to Postgres if you want
- compute the shortest and longest distance to the shoreline in Spatial SQL

'''

import pandas.io.sql as sql

from sqlalchemy import create_engine
from bokeh.embed import components
from bokeh.plotting import figure, output_file, output_notebook
from bokeh.resources import INLINE
from bokeh.models import ColumnDataSource
from bokeh.palettes import Spectral6
from bokeh.transform import factor_cmap
from bokeh.io import output_notebook, show

import numpy as np 

# Open a connection

# First you open a SSH tunnel if you have tunneling things to do
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 

#engine = create_engine('postgresql://xxxx:yyyyy@localhost:8005/savoie')
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')


# write a query
query = "select id, timestampgps, distance_to_colony from arctic.kap_hoegh_gls order by id, timestampgps"

# run the query and save the result in a df variable 
df = sql.read_sql_query(query, engine)

#(type of df is DataFrame)
type(df) #<class 'pandas.core.frame.DataFrame'>

# You get 8453 rows and 3 columns as expected
df.shape 
# (8453, 3) is dataset1
# (20380, 3) is dataset2
# (28833, 3) is dataset1+dataset2

df.columns
#'id', 'timestampgps', 'distance_to_colony'

#output_file("arctox_fig_all.html")
output_notebook()

# http://bokeh.pydata.org/en/latest/docs/user_guide/plotting.html#bars
p = figure( plot_width=1600, plot_height=600, title="Migration of birds : evolution of their position relatively to colony location", 
    x_axis_type='datetime')

p.circle(x=df['timestampgps'], y=df['distance_to_colony'], radius=0.9, fill_color='navy')
show(p)

######################
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')

# write a query
query = "select clean_lat as lat from arctic.kap_hoegh_gls where clean_lat is not null "

# run the query and save the result in a df variable 
df = sql.read_sql_query(query, engine)

df.columns

output_notebook() 
hist, edges = np.histogram(df['lat']) 


p1 = figure(title="latitude",background_fill_color="#E8DDCB") 

p1.quad(top=hist, bottom=0, left=edges[:-1], right=edges[1:], 
     fill_color="#036564", line_color="#033649") 
show(p1) 