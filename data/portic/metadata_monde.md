# 1. Metadata about shoreline

How Trait_cote_monde_xxxxxx.geoson was built.

- [1. Metadata about shoreline](#1-metadata-about-shoreline)
  - [1.1. NOAA shorelines](#11-noaa-shorelines)
  - [1.2. Download on 25 may 2020](#12-download-on-25-may-2020)
  - [Then we reduce the size by using advices on https://makina-corpus.com/blog/metier/2014/reduire-le-poids-dun-geojson](#then-we-reduce-the-size-by-using-advices-on-httpsmakina-corpuscomblogmetier2014reduire-le-poids-dun-geojson)
  - [1.3. Reducing size](#13-reducing-size)
    - [1.3.1. Open in QGIS :](#131-open-in-qgis-)
    - [1.3.2. Mapshaper](#132-mapshaper)
    - [1.3.3. Minify json](#133-minify-json)
    - [1.3.4. Set into data directory of Web application](#134-set-into-data-directory-of-web-application)

## 1.1. NOAA shorelines

https://www.ngdc.noaa.gov/mgg/shorelines/

Global Self-consistent, Hierarchical, High-resolution Geography Database (GSHHG) is a high-resolution geography data set, amalgamated from two databases: World Vector Shorelines (WVS) and CIA World Data Bank II (WDBII). The former is the basis for shorelines while the latter is the basis for lakes, although there are instances where differences in coastline representations necessitated adding WDBII islands to GSHHG. The WDBII source also provides political borders and rivers. GSHHG data have undergone extensive processing and should be free of internal inconsistencies such as erratic points and crossing segments. The shorelines are constructed entirely from hierarchically arranged closed polygons.

GSHHG combines the older GSHHS shoreline database with WDBII rivers and borders, available in either ESRI shapefile format or in a native binary format. Geography data are in five resolutions: crude(c), low(l), intermediate(i), high(h), and full(f). Shorelines are organized into four levels: boundary between land and ocean (L1), boundary between lake and land (L2), boundary between island-in-lake and lake (L3), and boundary between pond-in-island and island (L4). Datasets are in WGS84 geographic (simple latitudes and longitudes; decimal degrees).

GSHHG is released under the GNU Lesser General Public license, and is developed and maintained by Dr. Paul Wessel, SOEST, University of Hawai'i, and Dr. Walter H. F. Smith, NOAA Laboratory for Satellite Altimetry. Please notify Dr. Paul Wessel and Dr. Walter H.F. Smith if any changes are made to the GSHHG data set for commercial use.

Download GSHHG data version 2.3.7 (June 15, 2017) (Access Older versions)
GSHHG data are also available at: SOEST server. See readme.txt documentation.
Processing and assembly of the GSHHG data:
Wessel, P., and W. H. F. Smith (1996), A global, self-consistent, hierarchical, high-resolution shoreline database, J. Geophys. Res., 101(B4), 8741–8743, doi:10.1029/96JB00104.

------------------------------------------------------------------------------------------------------------------
## 1.2. Download on 25 may 2020

Keep version i layer L1

Then we reduce the size by using advices on https://makina-corpus.com/blog/metier/2014/reduire-le-poids-dun-geojson
-------------------------------------------------------------------------------------------------------------------

## 1.3. Reducing size

### 1.3.1. Open in QGIS : 
export as geojson, but simplify decimal (3) and remove useless columns

### 1.3.2. Mapshaper
Then go on : https://mapshaper.org/

Simplified at 70% using https://mapshaper.org/
Keep islands, and repair topology
Export in geojson and topojson formats, with the option to round (2 decimals)
precision = 0.01 

### 1.3.3. Minify json
Then minify to remove spaces and \n
https://www.webtoolkitonline.com/json-minifier.html
Download and rename xxxxxx.geojson

### 1.3.4. Set into data directory of Web application

Change the name of data accordingly to the xxxx filename into :
src\Components\OL\layerswitcher.js
src\Components\OL\layerswitcher-flows.js

import monde from "./data/trait_cote_monde_gshhs_i_L1_4326_minified2dec.geojson";
