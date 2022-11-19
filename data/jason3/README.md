# JASON 3 altimetric mission 

Create a web page to visualize the [GDR](https://www.aviso.altimetry.fr/en/data/products/sea-surface-height-products/global/gdr-igdr-and-ogdr.html) level data 
of [Jason-3 altimetric mission](https://podaac.jpl.nasa.gov/JASON3) which was launched in 2016. 

Download data from the ftp server of https://www.aviso.altimetry.fr/en/home.html. 
For  instance, the track 70  which passes near the ile d'Aix. 
The data is in netCDF format. 

Read the dataset with xarray, with the help of following code:
```py
import xarray as xr
file = r'JA3_GPN_2PfP310_070_20220730_030014_20220730_035627.nc'
ds = xr.open_dataset(file,group='data_20')
```

We have several variables (distance to coast, altitude, angel of approach etc.) available in the dataset for a particular track.
Project is about how to visualize the GDR level data of any track selected by the user

Here are few ideas from Nushrat (2022).

![The main view]("Project Idea.png"  The main view)


