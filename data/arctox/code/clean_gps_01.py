import numpy as np
import matplotlib.pyplot as plt
from tsmoothie.smoother import * #pip install tsmoothie

import pandas.io.sql as sql
from sqlalchemy import create_engine
from sqlalchemy import text

from bokeh.plotting import show, figure, output_file, output_notebook


# Open a connection

# First you open a SSH tunnel if you have tunneling things to do
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 

engine = create_engine('postgresql://xxxx:yyyyy@localhost:8005/savoie')
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')


query= """select pkid, id, timestampgps, lat, clean_lat, long, clean_long 
    from arctic.kap_hoegh_gls 
    order by id, timestampgps"""


df = sql.read_sql_query(query, engine)
df.shape #(28833, 7)

## From now, adapt the code
## https://stackoverflow.com/questions/20618804/how-to-smooth-a-curve-in-the-right-way

x = np.linspace(0,2*np.pi,100)
y = np.sin(x) + np.random.random(100) * 0.2

# operate smoothing
smoother = ConvolutionSmoother(window_len=5, window_type='ones')
smoother.smooth(y)

# generate intervals
low, up = smoother.get_intervals('sigma_interval', n_sigma=2)

### End of adaptation

# plot the smoothed timeseries with intervals

#output_notebook() 
output_file("smoothed_data.html")

p = figure(plot_width=800, plot_height=400)

# add a line renderer for smoothed line
p.line(x, smoother.smooth_data[0], line_width =3, color='blue')
p.circle(x, smoother.data[0], size =3, fill_color="white")
# add an area between low and up smoothed data
p.varea(x=x,y1=low[0], y2=up[0], alpha=0.3)

show(p)
