import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tsmoothie.smoother import * #pip install tsmoothie

import pandas.io.sql as sql
from sqlalchemy import create_engine
from sqlalchemy import text

from bokeh.plotting import show, figure, output_file, output_notebook


# Open a database connection

# First you open a SSH tunnel if you have tunneling things to do
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 

#engine = create_engine('postgresql://edgar:edgarM2@localhost:8005/savoie')
#engine = create_engine('postgresql://maliha:malihaM2@localhost:8007/savoie')
#engine = create_engine('postgresql://pp:ppM2@localhost:8007/savoie')
#engine = create_engine('postgresql://xxxx:yyyyy@localhost:8005/savoie')
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')

query= """select pkid, id, timestampgps, lat, clean_lat, long, clean_long 
    from arctic.kap_hoegh_gls 
    order by id, timestampgps """
df = sql.read_sql_query(query, engine)

'''
##Read from CSV file
#https://pandas.pydata.org/pandas-docs/version/0.22.0/io.html

import pandas as pd

df = pd.read_csv("C:\Travail\CNRS_mycore\Cours\Cours_M2_python\Projet_Arctox\gps.csv", sep=';')
'''

df.shape #(28833, 7)
df.columns 
'''
Index(['id', 'sex', 'dategps', 'timegps', 'timestampgps', 'lat', 'long',
       'pointgps', 'distance_to_colony', 'week', 'clean_lat', 'pkid',
       'smooth_lat', 'clean_long', 'smooth_long', 'point3857'],
      dtype='object')
'''


## From now, adapt the code for smoothing bad latitudes
## https://stackoverflow.com/questions/20618804/how-to-smooth-a-curve-in-the-right-way

x = df.iloc[:, 2].values #timestampgps
y = df.loc[:,['clean_lat']].values

# operate smoothing

#First simplest one : moving average of span = 5
#smoother = ConvolutionSmoother(window_len=5, window_type='ones')
#smoother.smooth(y)

#https://pypi.org/project/tsmoothie/
#https://fr.wikipedia.org/wiki/Fen%C3%AAtrage 
#Second one : moving weighted average of span = 10, using hamming function
smoother = ConvolutionSmoother(window_len=20, window_type='hamming')
smoother.smooth(y)

# generate intervals
low, up = smoother.get_intervals('sigma_interval', n_sigma=2)

### End of adaptation

# plot the smoothed timeseries with intervals

#output_notebook() 
output_file("smoothed_data.html")

p = figure(plot_width=1600, plot_height=800, x_axis_type='datetime')

# add a line renderer for smoothed line
p.line(x, smoother.smooth_data[0], line_width =3, color='blue')
p.circle(x, smoother.data[0], size =3, fill_color="white")
# add an area between low and up smoothed data
p.varea(x=x,y1=low[0], y2=up[0], alpha=0.3)


#show(p)

#Save the result
df['smooth_lat'] = smoother.smooth_data[0]

'''
#Save the result in database
with engine.connect() as con:
    con.execute("alter table arctic.kap_hoegh_gls add column if not exists smoothlat float")

with engine.connect() as con:
    for pkid in df['pkid']:
        lat = df.loc[df['pkid']==pkid,'smooth_lat'].values[0]
        query = "update arctic.kap_hoegh_gls g set smoothlat=%f where g.pkid =%d" % (lat, pkid)
        #print(query)
        rs = con.execute(query)
'''
        