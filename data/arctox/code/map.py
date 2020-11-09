# https://docs.bokeh.org/en/latest/docs/user_guide/geo.html
from bokeh.plotting import figure, output_file, show
from bokeh.tile_providers import CARTODBPOSITRON, get_provider

output_file("tile.html")

tile_provider = get_provider(CARTODBPOSITRON)

# range bounds supplied in web mercator coordinates
# p = figure(x_range=(-2000000, 6000000), y_range=(-1000000, 7000000),
#           x_axis_type="mercator", y_axis_type="mercator")
# 3857 EPSG

# Modify the bounding boxes with those of arctic points
# Using that -86.1200000000000045,-31.2199999999999989 : 30.0,75.5499999999999972
p = figure(x_range=(-9587947, 0), y_range=(3503549, 13195489),
           x_axis_type="mercator", y_axis_type="mercator")

p.add_tile(tile_provider)
 
show(p)

