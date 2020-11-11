# SQL, R and Python code for this project

## Read and plot

- plot01.py : look at the evolution of distance to the colony (before cleaning) during time
![plot01.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_plot01.png "one bird path")

## Python + SQL

- join_data_with_GPS.py : join and update spatial data associated with data_for_analyses

- clean_gps.py : to finish
- clean_gps_02.py : smoothing of bad lat + option for reading data from CSV file + option for **saving result into a database using SQL update**
![clean_gps_02.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_plot_smoothed_lat.png "smoothed lat")

## Read and map


- map.py : map background with OpenStreetMap

![map.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_map.png "map background")

- map01.py : map points of all birds locations

![map01.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_map01.png "all points in 3857 EPSG")

- map02.py : map migratory paths of all birds, for each individual, distinguising sex 

![map02.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_map02.png "migratory paths")

- map03.py : map trajectory of one  bird, with points that are colored according to elapsed time since the start of the migration

![map03.png](https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/code/fig/bokeh_map03.png "one bird path")


## Do spatio-temporal clustering


- stdbscan : to finish

