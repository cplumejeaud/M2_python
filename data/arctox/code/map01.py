# https://docs.bokeh.org/en/latest/docs/user_guide/geo.html
from bokeh.plotting import figure, output_file, show, output_notebook
from bokeh.tile_providers import CARTODBPOSITRON, get_provider

from bokeh.models import ColumnDataSource

import pandas.io.sql as sql
from sqlalchemy import create_engine




## Extract the data from sql database
## Open an ssh tunnel in Windows cmd line or Mac Terminal
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 
## Change here with the correct user, password 
## Open the connection
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')
# write a query that retrieve the x and y positions of points in 3857 EPSG
query = """select id, timestampgps, distance_to_colony, st_x(k.pt), st_y(k.pt) 
        from
        (
            select id, timestampgps, distance_to_colony, 
            st_setsrid(st_transform(st_setsrid(st_makepoint(long, lat), 4326), 3857), 3857) as pt
            from arctic.kap_hoegh_gls 
            where lat < 85 and lat > 35 and (long < 75 and long > -75)
            order by id, timestampgps
        ) as k
    """
# Remove this filtering clause and look at the result
# where lat < 85 and lat > 35 and (long < 75 and long > -75)

# run the query and save the result in a df variable 
df = sql.read_sql_query(query, engine)

df.columns
#Index(['id', 'timestampgps', 'distance_to_colony', 'st_x', 'st_y'], dtype='object')

## Do the map
output_file("arctox_map.html")
#output_notebook()


tile_provider = get_provider(CARTODBPOSITRON)

# Ranges matches this bbox in long/lat (-86.13, 30) (10, 75.6)
# select st_setsrid(st_transform(st_setsrid(st_makebox2d(st_point(-86.13, 30),  st_point(10, 75.6)), 4326), 3857), 3857)

# expected an element of either String or List(Tuple(String, String))
# range bounds supplied in web mercator coordinates
p = figure(x_range=(-9587947, 1113194), y_range=(3503549, 13195489),
           x_axis_type="mercator", y_axis_type="mercator")

p.add_tile(tile_provider)

p.circle(x=df['st_x'], y=df['st_y'], size=1, fill_color="blue", fill_alpha=0.8)

show(p)

