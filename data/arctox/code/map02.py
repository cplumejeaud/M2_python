# https://docs.bokeh.org/en/latest/docs/user_guide/geo.html
from bokeh.plotting import figure, output_file, show, output_notebook
from bokeh.tile_providers import CARTODBPOSITRON, get_provider  
from bokeh.models.mappers import CategoricalColorMapper
from bokeh.models import ColumnDataSource, HoverTool

import pandas.io.sql as sql
from sqlalchemy import create_engine




## Extract the data from sql database
## Open an ssh tunnel in Windows cmd line or Mac Terminal
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 
## Change here with the correct user, password 
## Open the connection
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')
# write a query that retrieve the lines of birds trajectory in 3857 EPSG
query = """
        select bird_id, sex, x_path_coordinates, y_path_coordinates 
        from arctic.data_for_analyses where bird_path is not null
        
    """



# run the query and save the result in a df variable 
df = sql.read_sql_query(query, engine)

df.columns
#Index(['bird_id', 'sex', 'x_path_coordinates', 'y_path_coordinates'], dtype='object')

## Do the map

output_file("arctox_map2.html")
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

color_mapper = CategoricalColorMapper(palette=["blue", "pink"], factors=["M", "F"])

#p.multi_line(df.iloc[0:1, 2], df.iloc[0:1, 3], color='blue', line_width=1)
p.multi_line('x_path_coordinates', 'y_path_coordinates', source=msource, color={'field': 'sex', 'transform': color_mapper}, line_width=1)

#p.line(df.iloc[3, 2], df.iloc[3, 3], color='red', line_width=2)
p.line(df.loc[df['bird_id']=='LIAK11EG12', 'x_path_coordinates'].values[0], df.loc[df['bird_id']=='LIAK11EG12', 'y_path_coordinates'].values[0], color='red', line_width=2)

#print(df.loc[df['bird_id']=='LIAK11EG12', 'x_path_coordinates'].values[0])
#print (df.iloc[3, 2])
print (df.iloc[3, 0])

show(p)

