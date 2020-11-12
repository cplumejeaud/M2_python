/*
M2 La Rochelle University - 2020-2021
Christine PLUMEJEAUD-PERREAU, U.M.R. 7266 LIENSS
Master class : Relational DBMS and Geographic information
ARCTOX project - SQL script
*/

-- create a table sites

--create schema arctic

set search_path = 'arctic', public;
set search_path = 'poisson_yasser', public;

CREATE TABLE poisson_yasser.sites (
	pkid serial NOT NULL,
	sampling_site text NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	country text NULL,
	"_2015" bool NULL,
	"_2016" bool NULL,
	"_2017" bool NULL,
	point_loc geometry NULL,
	CONSTRAINT sites_pkey PRIMARY KEY (pkid)
);

-- run with DBeaver this file
-- https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/sites_202010191553.sql
-- This import site data into sites table

-- Use DBeaver to import the CSV file Kap Hoegh GLS 20102011_sun3.csv 
create table kap_hoegh_gls_backup as (select * from kap_hoegh_gls)
drop table kap_hoegh_gls
-- Use DBeaver to import the CSV file complet.csv 
alter table complet_csv rename to kap_hoegh_gls


alter table kap_hoegh_gls drop column id_id;

SHOW DATESTYLE;
-- ISO, DMY

select 1+5

select '15/10/2010'::date

alter table kap_hoegh_gls rename column date to dategps;
alter table kap_hoegh_gls alter column dategps type date USING dategps::date;

alter table kap_hoegh_gls rename column time to timegps;
alter table kap_hoegh_gls alter column timegps type time USING timegps::time;

select  (dategps ||' '|| timegps)::timestamp from kap_hoegh_gls;

alter table kap_hoegh_gls add column timestampgps timestamp ;
update kap_hoegh_gls set timestampgps =  (dategps ||' '|| timegps)::timestamp;

select st_makepoint(long::float, lat_compensate::float) from kap_hoegh_gls

---
select * from kap_hoegh_gls g, kap_hoegh_gls_backup b
where g.id = b.id and g.timestampgps = b.timestampgps and g.id = '3689' 

select * from kap_hoegh_gls g
where g.id = '3679'
select * from kap_hoegh_gls_backup g
where g.id = '3689'

select distinct id from kap_hoegh_gls g order by id

select id from kap_hoegh_gls g
where id in (
select distinct id from bird_paths bp )
3679
----

select replace(long, ',', '.') from kap_hoegh_gls
select replace(lat_compensate, ',', '.') from kap_hoegh_gls

select st_makepoint(replace(long, ',', '.')::float, replace(lat_compensate, ',', '.')::float) from kap_hoegh_gls
alter table kap_hoegh_gls add column  pointgps geometry;

-- dans le premier fichier : long et lat_compensate
update kap_hoegh_gls set pointgps =  st_makepoint(replace(long, ',', '.')::float, replace(lat_compensate, ',', '.')::float);
-- dans le second fichier Kap Hoegh GLS 20102011_sun3.csv : long2 et lat2
update kap_hoegh_gls set pointgps =  st_makepoint(replace(long2, ',', '.')::float, replace(lat2, ',', '.')::float);

-- Indiquer la projection
update kap_hoegh_gls set pointgps = st_setsrid(pointgps, 4326) 



--- Récupérer les coordonnées du site de la colonie du Kap Hoegh
select point_loc 
from sites s 
where s.sampling_site = 'Kap_Hoegh'


-- Calculer la distance à la colonie pour chaque point, chaque oiseau, chaque instant
-- ordonnée par oiseau et par date
-- attention, comme nous ne sommes pas en coordonnées projetées mais en coordonnées géographiques (EPSG = 4326)
-- il faut utiliser la distance sphérique (qui sera exprimée en mètre)
select id, timestampgps, round(st_distance_sphere(p.pointgps, s.point_loc) / 1000)
from sites s, kap_hoegh_gls p 
where s.sampling_site = 'Kap_Hoegh'
order by id, timestampgps

-- use st_distance(p.pointgps, s.point_loc, true) instead of st_distance_sphere
select id, timestampgps, round(st_distance(p.pointgps, s.point_loc, true) / 1000)
from sites s, kap_hoegh_gls p 
where s.sampling_site = 'Kap_Hoegh'
order by id, timestampgps

-- add a new column distance_to_colony to record the result
alter table kap_hoegh_gls add column distance_to_colony float;

-- record the computed value (in KM)
update kap_hoegh_gls set distance_to_colony = st_distance(pointgps, s.point_loc, true) / 1000
from sites s 
where s.sampling_site = 'Kap_Hoegh'
-- 8453 lines
-- 203380

-- Look at the result
select id, timestampgps, distance_to_colony
from kap_hoegh_gls
order by id, timestampgps


select distinct id from kap_hoegh_gls

select distinct gls_id from data_for_analyses dfa 
-- Let's have a look on the data to understand by using a plot 
-- with Bokeh
-- with R


alter table kap_hoegh_gls add pkid serial primary KEY;
select id, ROW_NUMBER () OVER (PARTITION BY id  ORDER by timestampgps) as point_rank
from kap_hoegh_gls

alter table kap_hoegh_gls add point_rank integer;
update kap_hoegh_gls g set point_rank = k.point_rank
from 
	(select id, timestampgps, ROW_NUMBER () OVER (PARTITION BY id  ORDER by timestampgps) as point_rank
	from kap_hoegh_gls) as k
where k.id = g.id and k.timestampgps = g.timestampgps;

select pkid, id, sex, timestampgps, point_rank from kap_hoegh_gls
order by timestampgps

-- we need a current point, and a next point
select loc.id, loc.timestampgps , loc.pkid,  nextp.timestampgps, nextp.pkid
from kap_hoegh_gls loc, kap_hoegh_gls nextp
where loc.id = nextp.id and loc.timestampgps < nextp.timestampgps
and nextp.timestampgps = (select min(timestampgps) from kap_hoegh_gls where loc.timestampgps < timestampgps and id = loc.id)

-----------------------------------------------------------------------------

-- Now we would like to compute the path 
-- let's compute the path
select id, st_makeline(pointgps)
from (
	select id, pointgps, timestampgps from kap_hoegh_gls order by id, timestampgps
) as q 
group by id

-- create a table bird_paths to save the result
create table bird_paths as (
	select id, st_makeline(pointgps) as linepath
	from (select id, pointgps, timestampgps from kap_hoegh_gls order by id, timestampgps) as q 
	group by id
	)

-- insert new points
insert into bird_paths (id, linepath) 
	(	select id, st_makeline(pointgps) as linepath
		from (select id, pointgps, timestampgps from kap_hoegh_gls order by id, timestampgps) as q 
		group by id
	)
-- 44
	
select count(*) from arctic.bird_paths
-- 18 + 44 = 62
select distinct id from arctic.bird_paths

	
select id, st_asgeojson(linepath) from bird_paths

/*
Concerning ARCTOX project 


Here is the job planned for TEA tomorrow afternoon : 
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

All spatial documentation is here https://postgis.net/docs/
*/

-- importer par DBeaver le fichier Excel data_for_analyses (le bon onglet!)
-- Voici l'allure de la table créée automatiquement
-- https://github.com/cplumejeaud/M2_python/blob/main/data/arctox/data%20for%20analyses_2010_2011_analyses.csv
CREATE TABLE arctic.data_for_analyses (
	"Year" varchar(1024) NULL,
	bird_id varchar(1024) NULL,
	gls_id varchar(1024) NULL,
	sex varchar(1024) NULL,
	"Date" varchar(1024) NULL,
	nest varchar(1024) NULL,
	nest_content varchar(1024) NULL,
	capture_method varchar(1024) NULL,
	headbill varchar(1024) NULL,
	culmen varchar(1024) NULL,
	wing varchar(1024) NULL,
	right_tarsus varchar(1024) NULL,
	mass varchar(1024) NULL,
	index_body_condition varchar(1024) NULL,
	muscle_pectoral varchar(1024) NULL,
	score_personal varchar(1024) NULL,
	long_egg varchar(1024) NULL,
	long_egg_cm varchar(1024) NULL,
	larg_egg varchar(1024) NULL,
	larg_egg_cm varchar(1024) NULL,
	vol_egg varchar(1024) NULL,
	arrival_date varchar(1024) NULL,
	arrival_date_num varchar(1024) NULL,
	arrival_date_propre varchar(1024) NULL,
	arrival_date_propre_num varchar(1024) NULL,
	date_enter_nest varchar(1024) NULL,
	date_enter_nest_num varchar(1024) NULL,
	hatch_date varchar(1024) NULL,
	hatch_date_num varchar(1024) NULL,
	weigh_hatching varchar(1024) NULL,
	hatching_success varchar(1024) NULL,
	"Chick_mass_gain_(g/d)_1st_15d" varchar(1024) NULL,
	"pente_chick_growth_1-15d" varchar(1024) NULL,
	n_sia_blood varchar(1024) NULL,
	n_sia_head_feather varchar(1024) NULL,
	c_sia_blood varchar(1024) NULL,
	c_sia_head_feather varchar(1024) NULL,
	chick_sex varchar(1024) NULL,
	cortico varchar(1024) NULL,
	hg_hf varchar(1024) NULL,
	hg_blood varchar(1024) NULL,
	season_hg_blood varchar(1024) NULL,
	hg_bf varchar(1024) NULL,
	bf_side varchar(1024) NULL,
	long_median_15oct_20fev varchar(1024) NULL,
	lat_median_15oct_20fev varchar(1024) NULL,
	long_median_decjan varchar(1024) NULL,
	lat_median_decjan varchar(1024) NULL,
	long_median_dec_20fev varchar(1024) NULL,
	lat_median_dec_20fev varchar(1024) NULL,
	d_pl_15oct_20fev varchar(1024) NULL,
	d_pl_decjan varchar(1024) NULL,
	d_pl_1dec_20fev varchar(1024) NULL,
	max_d_col__dec_jan varchar(1024) NULL,
	max_d_col__15oct_20fev varchar(1024) NULL,
	pl_lat varchar(1024) NULL,
	pl_long varchar(1024) NULL
);

alter table data_for_analyses add column bird_path geometry;
comment on column data_for_analyses.bird_path is 'trajectory of the bird recorded with a GLS having 150 km of resolution';

-- id of kap_hoegh_gls are the id of the GPS in data_for_analyses table
update data_for_analyses d set bird_path = k.linepath
from (
	select id, st_makeline(pointgps) as linepath
	from (select id, pointgps, timestampgps from kap_hoegh_gls order by id, timestampgps) as q 
	group by id
) as k 
where k.id = d.gls_id
-- 0 : why ?

-- let's have a look to gls_id
select distinct gls_id from arctic.data_for_analyses
-- MK12-12A
-- MK18-
-- MK14-
-- SO-
select substring('MK12-12A151' from 9)


select length('MK12-12A') 
alter table arctic.data_for_analyses add column clean_glsid varchar;

select bird_id, gls_id, substring(upper(gls_id) from length('MK12-12A')+1) as clean
from arctic.data_for_analyses
where upper(gls_id) like 'MK12-12A%'
-- 12

select bird_id, substring(upper(gls_id) from length('MK18-')+1) as clean
from arctic.data_for_analyses
where upper(gls_id) like 'MK18-%'
-- 6

select bird_id,  substring(upper(gls_id) from length('MK14-')+1) as clean
from arctic.data_for_analyses
where upper(gls_id) like 'MK14-%'
-- 3

select bird_id, substring(upper(gls_id) from length('SO-')+1) as clean
from arctic.data_for_analyses
where upper(gls_id) like 'SO-%'
-- 13

update arctic.data_for_analyses d set clean_glsid = k.clean
from 
(
	select bird_id, substring(upper(gls_id) from length('MK12-12A')+1) as clean
	from arctic.data_for_analyses
	where upper(gls_id) like 'MK12-12A%'
	UNION
	select bird_id, substring(upper(gls_id) from length('MK18-')+1) as clean
	from arctic.data_for_analyses
	where upper(gls_id) like 'MK18-%'
	UNION	
	select bird_id,  substring(upper(gls_id) from length('MK14-')+1) as clean
	from arctic.data_for_analyses
	where upper(gls_id) like 'MK14-%'
	UNION
	select bird_id, substring(upper(gls_id) from length('SO-')+1) as clean
	from arctic.data_for_analyses
	where upper(gls_id) like 'SO-%'
	UNION
	select bird_id, gls_id as clean
	from arctic.data_for_analyses
	where upper(gls_id) not like 'NA' and upper(gls_id) not like 'SO-%' and upper(gls_id) not like 'MK14-%' and upper(gls_id) not like 'MK18-%' and  upper(gls_id) not like 'MK12-12A%'
) as  k 
where d.bird_id = k.bird_id
-- 81

SELECT pg_typeof(gls_id) from arctic.data_for_analyses ;



select distinct bird_id, gls_id, clean_glsid 
from arctic.data_for_analyses
order by clean_glsid


-- id of kap_hoegh_gls are the clean_glsid of the GPS in data_for_analyses table
update data_for_analyses d set bird_path = k.linepath
from (
	select id, st_makeline(pointgps) as linepath
	from (select id, pointgps, timestampgps from kap_hoegh_gls order by id, timestampgps) as q 
	group by id
) as k 
where k.id = d.clean_glsid
-- 18 + ?  = 42

select count(*) from arctic.data_for_analyses where upper(gls_id) like 'MK12-12A%'
-- create a column for the length of the path
alter table data_for_analyses add column migration_length float;
update data_for_analyses set migration_length = round(st_length(bird_path, true)/ 1000);

select count(*) from kap_hoegh_gls where id = '3653'

-- select data for analysis 
select distinct bird_id, gls_id, clean_glsid , sex, wing, mass , migration_length 
from arctic.data_for_analyses
where bird_path is not null
order by clean_glsid 


-- -86.1200000000000045,-31.2199999999999989 : 30,75.5499999999999972
select st_makebox2d(st_point(-86.13, 30),  st_point(10, 75.6))
select st_setsrid(st_makebox2d(st_point(-86.13, 30),  st_point(10, 75.6)), 4326)
select st_setsrid(st_transform(st_setsrid(st_makebox2d(st_point(-86.13, 30),  st_point(10, 75.6)), 4326), 3857), 3857)
-- POLYGON ((-9587947.742024653 3503549.843504374, -9587947.742024653 13195489.532180473, -3473168.1127501344 13195489.532180473, -3473168.1127501344 3503549.843504374, -9587947.742024653 3503549.843504374))
-- POLYGON ((-9587947.742024653 3503549.843504374, -9587947.742024653 13195489.532180473, 0 13195489.532180473, 0 3503549.843504374, -9587947.742024653 3503549.843504374))
-- POLYGON ((-9587947.742024653 3503549.843504374, -9587947.742024653 13195489.532180473, 1113194.9079327343 13195489.532180473, 1113194.9079327343 3503549.843504374, -9587947.742024653 3503549.843504374))
-- POLYGON ((-9587947 3503549, -9587947 13195489, 1113194 13195489, 1113194 3503549, -9587947 3503549))

select id, timestampgps, distance_to_colony, st_x(k.pt), st_y(k.pt) 
from
(
select id, timestampgps, distance_to_colony, st_setsrid(st_transform(pointgps, 3857), 3857) as pt
from arctic.kap_hoegh_gls 
where replace(lat_compensate, ',', '.')::float < 90 and replace(lat_compensate, ',', '.')::float > 30
order by id, timestampgps
) as k

select count(*) from complet_csv cc 




select gls_id , clean_glsid from data_for_analyses where migration_length is null and long_median_15oct_20fev is not null and long_median_15oct_20fev<>'NA'
-- 1 : 3506 

-- fusionner les deux tables : kap_hoegh_gls et kap_hoegh_gls_backup
alter table kap_hoegh_gls rename to kap_hoegh_gls_dataset2;
alter table kap_hoegh_gls_backup rename to kap_hoegh_gls_dataset1;
drop table kap_hoegh_gls
create table kap_hoegh_gls as (
	select id, sex, dategps, timegps, timestampgps, replace(lat2, ',', '.')::float as lat, replace(long2, ',', '.')::float  as long, pointgps, distance_to_colony, extract(week from dategps) as week
	from kap_hoegh_gls_dataset2
	union 
	select id, sex, dategps, timegps, timestampgps, replace(lat_compensate, ',', '.')::float  as lat, replace(long, ',', '.')::float as long, pointgps,  distance_to_colony, extract(week from dategps) as week 
	from kap_hoegh_gls_dataset1
) --28833


select id, timestampgps, distance_to_colony, st_x(k.pt), st_y(k.pt) 
from
(
select id, timestampgps, distance_to_colony, st_setsrid(st_transform(pointgps, 3857), 3857) as pt
from arctic.kap_hoegh_gls 
where lat < 90 and lat > 30
order by id, timestampgps
) as k

alter table kap_hoegh_gls add column if not exists pkid serial;

alter table kap_hoegh_gls add column if not exists clean_lat float null;
update kap_hoegh_gls set clean_lat = null;
update kap_hoegh_gls set clean_lat = lat where lat < 85 and lat > 35; -- 26974 lines

alter table kap_hoegh_gls add column smooth_lat float;
alter table kap_hoegh_gls add column clean_long float;
alter table kap_hoegh_gls add column smooth_long float;

update kap_hoegh_gls set clean_long = null;
update kap_hoegh_gls set clean_long = long where long < 75 and long > -75; -- 26974 lines

-- quelle est la distribution des latitudes


-- we need a current point, and a next point
select loc.id, loc.timestampgps , loc.pkid,  loc.clean_lat, nextp.timestampgps, nextp.pkid, nextp.clean_lat
from kap_hoegh_gls loc, kap_hoegh_gls nextp
where loc.id = nextp.id and loc.clean_lat is null and loc.timestampgps < nextp.timestampgps
and nextp.timestampgps = (select min(timestampgps) from kap_hoegh_gls where loc.timestampgps < timestampgps and id = loc.id and clean_lat is not null)


-- we need a previous point, a current point to fix, and a next point
select prevp.pkid, prevp.timestampgps, prevp.clean_lat, loc.pkid, loc.id, loc.timestampgps , loc.clean_lat, nextp.pkid, nextp.timestampgps, nextp.clean_lat
from kap_hoegh_gls prevp, kap_hoegh_gls loc, kap_hoegh_gls nextp
where loc.clean_lat is null  
and loc.id = nextp.id and loc.timestampgps < nextp.timestampgps
and nextp.timestampgps = (select min(timestampgps) from kap_hoegh_gls where loc.timestampgps < timestampgps and id = loc.id and clean_lat is not null)
and loc.id = prevp.id and  loc.timestampgps > prevp.timestampgps
and prevp.timestampgps = (select max(timestampgps) from kap_hoegh_gls where loc.timestampgps > timestampgps and id = loc.id and clean_lat is not null)

update kap_hoegh_gls g set clean_lat = (previouslat+nextlat)/2
from 
(
select prevp.pkid, prevp.timestampgps, prevp.clean_lat as previouslat, loc.pkid as rowid, loc.id, loc.timestampgps , loc.clean_lat, nextp.pkid, nextp.timestampgps, nextp.clean_lat as nextlat
from kap_hoegh_gls prevp, kap_hoegh_gls loc, kap_hoegh_gls nextp
where loc.clean_lat is null  
and loc.id = nextp.id and loc.timestampgps < nextp.timestampgps
and nextp.timestampgps = (select min(timestampgps) from kap_hoegh_gls where loc.timestampgps < timestampgps and id = loc.id and clean_lat is not null)
and loc.id = prevp.id and  loc.timestampgps > prevp.timestampgps
and prevp.timestampgps = (select max(timestampgps) from kap_hoegh_gls where loc.timestampgps > timestampgps and id = loc.id and clean_lat is not null)
) as k 
where k.rowid = g.pkid and g.clean_lat is null

update kap_hoegh_gls g set clean_long = (previouslong+nextlong)/2
from 
(
select prevp.pkid, prevp.timestampgps, prevp.clean_long as previouslong, loc.pkid as rowid, loc.id, loc.timestampgps , loc.clean_long, nextp.pkid, nextp.timestampgps, nextp.clean_long as nextlong
from kap_hoegh_gls prevp, kap_hoegh_gls loc, kap_hoegh_gls nextp
where loc.clean_long is null  
and loc.id = nextp.id and loc.timestampgps < nextp.timestampgps
and nextp.timestampgps = (select min(timestampgps) from kap_hoegh_gls where loc.timestampgps < timestampgps and id = loc.id and clean_long is not null)
and loc.id = prevp.id and  loc.timestampgps > prevp.timestampgps
and prevp.timestampgps = (select max(timestampgps) from kap_hoegh_gls where loc.timestampgps > timestampgps and id = loc.id and clean_long is not null)
) as k 
where k.rowid = g.pkid and g.clean_long is null

-- Clean the lat and long done
-- Do the smoothing
-- See R script or python script

-- Update data
drop table smoothed ;



select bird_id, sex, bird_path from arctic.data_for_analyses where bird_path is not null
select postgis_full_version() 
-- POSTGIS="2.5.2 r17328" [EXTENSION] PGSQL="110" GEOS="3.7.0-CAPI-1.11.0 3.7.1" PROJ="Rel. 4.9.3, 15 August 2016" GDAL="GDAL 2.2.4, released 2018/03/19" LIBXML="2.7.8" LIBJSON="0.12" LIBPROTOBUF="1.2.1" RASTER

alter table data_for_analyses add column if not exists x_path_coordinates float[];
alter table data_for_analyses add column if not exists y_path_coordinates float[];


-- redo after cleaning of lat and long
update kap_hoegh_gls g set smooth_lat = s.smooth_lat, smooth_long = s.smooth_long
from smoothed s where g.pkid = s.pkid


update kap_hoegh_gls set pointgps = st_setsrid(st_makepoint(smooth_long, smooth_lat), 4326) where smooth_lat is not null;

alter table arctic.kap_hoegh_gls add if not exists point3857 geometry;
update arctic.kap_hoegh_gls set point3857 = st_setsrid(st_transform(pointgps, 3857), 3857) ;

update arctic.data_for_analyses d set bird_path = k.linepath
from (
	select id, st_makeline(pointgps) as linepath
	from (select id, pointgps, timestampgps from arctic.kap_hoegh_gls order by id, timestampgps) as q 
	group by id
) as k 
where k.id = d.clean_glsid;

-- alter table arctic.data_for_analyses add column if not exists curvedpath geometry;
-- update arctic.data_for_analyses set curvedpath = ST_LineToCurve(bird_path)
-- alter table arctic.data_for_analyses drop  column curvedpath

update arctic.data_for_analyses set migration_length = round(st_length(bird_path, true)/ 1000);

update arctic.data_for_analyses d set x_path_coordinates = k.x_linepath, y_path_coordinates=k.y_linepath
from (
	select id, array_agg(st_x(pt3857)) as x_linepath, array_agg(st_y(pt3857)) as y_linepath
	from (select id, point3857 as pt3857, timestampgps 
		from arctic.kap_hoegh_gls 
		order by id, timestampgps) as q 
	group by id
) as k 
where k.id = d.clean_glsid;

--------------------
-- Test spatial clustering with postgis
-- https://postgis.net/docs/ST_ClusterDBSCAN.html
-------------------
drop table arctic.spatial_cluster
create table arctic.spatial_cluster as (
	SELECT cid, ST_Collect(pointgps) AS cluster_geom, array_agg(pkid) AS pkids_in_cluster 
	FROM (
	    SELECT pkid, ST_ClusterDBSCAN(point3857, eps := 250000, minpoints := 5) over () AS cid, pointgps
	    FROM arctic.kap_hoegh_gls) sq
	GROUP BY cid
)

select * from arctic.spatial_cluster

create table arctic.spatial_cluster as (
	SELECT id, cid, ST_Collect(pointgps) AS cluster_geom, array_agg(pkid) AS pkids_in_cluster, array_agg(id)  as ids_in_cluster
	FROM (
	    SELECT pkid, id, ST_ClusterDBSCAN(point3857, eps := 150000, minpoints := 10) over (PARTITION BY id) AS cid, pointgps
	    FROM arctic.kap_hoegh_gls ) sq
	GROUP BY id, cid
)

create table arctic.spatial_cluster as (
	SELECT id, cid, ST_Collect(pointgps) AS cluster_geom, array_agg(pkid) AS pkids_in_cluster, array_agg(id)  as ids_in_cluster
	FROM (
	    SELECT pkid, id, ST_ClusterDBSCAN(point3857, eps := 350000, minpoints := 5) over (PARTITION BY id) AS cid, pointgps
	    FROM arctic.kap_hoegh_gls ) sq
	GROUP BY id, cid
) -- TB

select avg(c), min(c), max(c), stddev(c) 
from (
	select id, count(cid) as c from arctic.spatial_cluster group by id 
) as k
-- 7 classes, plus ou moins 2

------------------------------------------------------------------
-- Draw their footprint
-- https://postgis.net/docs/ST_ConvexHull.html
------------------------------------------------------------------

alter table arctic.spatial_cluster add concave_hull geometry
update arctic.spatial_cluster set concave_hull = ST_ConcaveHull(cluster_geom, 0.80) where cid is not null
update arctic.spatial_cluster set concave_hull = ST_ConvexHull(cluster_geom) where cid is not null

------------------------------------------------------------------

-- Fix the distance to colony
update kap_hoegh_gls set distance_to_colony = st_distance(pointgps, s.point_loc, true) / 1000
from sites s 
where s.sampling_site = 'Kap_Hoegh'

select *, st_x(point3857) as x, st_y(point3857) as y from arctic.kap_hoegh_gls
update arctic.kap_hoegh_gls g set smoothlat=20490.000000 where g.pkid =52
alter table arctic.kap_hoegh_gls add column if not exists smoothlat float
alter table arctic.kap_hoegh_gls drop column smoothlat

------------------------------------------------------------------
-- import coastline
------------------------------------------------------------------

export PGCLIENTENCODING=utf8
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=8005 user=postgres dbname=savoie password=xxxxx schemas=arctic" C:\Travail\CNRS_mycore\Cours\Cours_M2_python\Projet_Arctox\trait_cote_monde_gshhs_i_L1_4326_minified2dec.geojson -a_srs EPSG:4326 -nln shoreline

select id, st_srid(wkb_geometry), st_area(wkb_geometry, true) 
from arctic.shoreline
where id = '7'
2113539963215.1765

-- Filter the set of shoreline you will use to compute the distance of birds to shoreline
alter table arctic.shoreline add column if not exists  keep boolean default false;
update arctic.shoreline set keep = true where st_area(wkb_geometry, true) > 1000000000
-- 293 entities

select count(*) from arctic.shoreline
-- 32 830

-- Add a projected new geom3857 using Mercator EPSG 3857 projection. 
-- This will allow for computing an euclidian distance which is less computive intensive

alter table arctic.shoreline add column if not exists  geom3857 geometry
update arctic.shoreline set geom3857 = st_setsrid(st_transform(wkb_geometry, 3857), 3857)
 
-- compute projecte area : not the same as in 4326 (due to a bad projection choice)
select id, st_srid(geom3857), st_area(geom3857) 
from arctic.shoreline
where id = '7'
34549486938499.723


------------------------------------------------------------------
-- compute distance to shoreline for each bird each time and record it into kap_hoegh_gls
------------------------------------------------------------------

-- Distance of all points to all shorelines
select pkid, st_distance(geom3857,point3857) as d
from arctic.shoreline , arctic.kap_hoegh_gls
where keep is true ;


-- Minimal distance per pkid (a point at a time of a bird) to all shorelines
select pkid, min(d) from 
(
	select pkid, st_distance(geom3857,point3857) as d
	from arctic.shoreline , arctic.kap_hoegh_gls g
	where keep is true and g.id = '148' 
) as k
group by pkid ;

-- store them in arctic.kap_hoegh_gls

alter table arctic.kap_hoegh_gls add column if not exists shoreline_distance float;

update arctic.kap_hoegh_gls g set shoreline_distance = mind
from
(
	select pkid, min(d) as mind from 
	(
		select pkid, st_distance(geom3857,point3857) as d
		from arctic.shoreline , arctic.kap_hoegh_gls g
		where keep is true and g.id = '148' 
	) as k
	group by pkid 
) as q
where g.id = '148' and q.pkid = g.pkid;

----------------------------------------------------------------------------------
-- analyse the distance (farthest, mean, median) and store in arctic.data_for_analyses
----------------------------------------------------------------------------------

alter table arctic.data_for_analyses add column if not exists max_shoreline_distance float;
update arctic.data_for_analyses d set max_shoreline_distance = round(maxd / 1000)
from
(
	select id, max(shoreline_distance) as maxd  
	from  arctic.kap_hoegh_gls g
	group by id 
) as q
where  q.id = d.clean_glsid ;
-- 499 points

select bird_id, clean_glsid, migration_length, max_shoreline_distance 
from arctic.data_for_analyses
where max_shoreline_distance is not null
-- 2182 km
-- LIAK11EG12	148	49560.0	2182.0

alter table arctic.data_for_analyses add column if not exists mean_shoreline_distance float;
update arctic.data_for_analyses d set mean_shoreline_distance = round(avgd / 1000)
from
(
	select id, avg(shoreline_distance) as avgd  
	from  arctic.kap_hoegh_gls g
	group by id 
) as q
where  q.id = d.clean_glsid ;


select bird_id, clean_glsid, migration_length, max_shoreline_distance, mean_shoreline_distance 
from arctic.data_for_analyses
where max_shoreline_distance is not null
