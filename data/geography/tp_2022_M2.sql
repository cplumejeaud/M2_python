------------------------------------
-- SQL script, 07 november 2022
-- Christine Plumejeaud-Perreau, UMR 7301 Migrinter
-- Lessons about DBMS Postgres and use of Postgis for master class
------------------------------------

create extension postgis;


CREATE ROLE createur_savoie NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'savoie';
CREATE ROLE lecteur_savoie NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'savoie';


select 'j''aime le sql';

-- première méthode

/*
shp2pgsql -c -I -W LATIN1 "C:\Travail\CNRS_poitiers\MIGRINTER\Labo\Louis_Fernier\demographie\DGURBA-2018-01M-SH\DGURBA_2018_01M" public.dgurba_2018 > C:\Travail\CNRS_poitiers\Cours\Cours_M2_python\BDD1\TP\toimport.sql
psql -U postgres -p 5432 -d savoie -f C:\Travail\CNRS_poitiers\Cours\Cours_M2_python\BDD1\TP\toimport.sql
*/


-- seconde méthode
/*
set PGCLIENTENCODING=latin1

ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 user=postgres dbname=savoie password=postgres schemas=public" "C:\Travail\CNRS_poitiers\MIGRINTER\Labo\IHMANA\data\Filosofi2017_carreaux_1km_shp\Filosofi2017_carreaux_1km_met.shp" -lco SPATIAL_INDEX=YES -preserve_fid -nln carreaux_1km

ALTER TABLE public.carreaux_1km ALTER COLUMN ind_snv TYPE double precision USING ind_snv::double precision;

truncate table public.carreaux_1km;

ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 user=postgres dbname=savoie password=postgres schemas=public" "C:\Travail\CNRS_poitiers\MIGRINTER\Labo\IHMANA\data\Filosofi2017_carreaux_1km_shp\Filosofi2017_carreaux_1km_met.shp" -append -lco SPATIAL_INDEX=YES -preserve_fid -nln carreaux_1km
*/

-- ou 
/*
shp2pgsql -c -I -W LATIN1 "C:\Travail\CNRS_poitiers\MIGRINTER\Labo\IHMANA\data\Filosofi2017_carreaux_1km_shp\Filosofi2017_carreaux_1km_met" public.carreaux_1km > C:\Travail\CNRS_poitiers\Cours\Cours_M2_python\BDD1\TP\carreaux.sql

psql -U postgres -p 5432 -d savoie -f C:\Travail\CNRS_poitiers\Cours\Cours_M2_python\BDD1\TP\carreaux.sql
*/
----------------------
-- après imports
----------------------

select count(*) from public.carreaux_1km ck ;
-- 374 797

select * from public.dgurba_2018 d 
where NUTS like 'FRI%'; -- Nouvelle-Aquitaine
-- 4405

select * from public.dgurba_2018 d 
where NUTS like 'FRI%' and population::int >= 300;
-- 2914 communes


select * from public.dgurba_2018 d 
where NUTS like 'FRI%' and population::int >= 300 and dgurba = 3;
-- 2605 communes

select count(*) from public.carreaux_1km c 
where ind >= 25;
-- 178 567

-- carreaux en wkb_geometry : 2154

-- sql spatiale
select st_srid(geom) from public.dgurba_2018 d ;
select st_astext(geom) from public.dgurba_2018 d limit 3 ;

-- rajouter une colonne
alter table public.dgurba_2018 add column geom_4326 geometry;
-- renseigner
update public.dgurba_2018 set geom_4326 = st_setsrid(geom, 4326);

/*
alter table public.dgurba_2018 add column geom_3035 geometry;
update public.dgurba_2018 set geom_3035 = st_setsrid(geom, 3035);
-- 102600
*/

alter table public.dgurba_2018 add column geom_2154 geometry;
--update public.dgurba_2018 set geom_2154 = st_setsrid(st_transform(geom_3035, 2154), 2154);
-- 102600
--update public.dgurba_2018 set geom_2154 = st_setsrid(st_transform(geom_3035, 2154), 2154);
update public.dgurba_2018 set geom_2154 = st_setsrid(st_transform(geom_4326, 2154), 2154);


select * 
from public.dgurba_2018 d , public.carreaux_1km c 
where st_contains(d.geom_2154, c.wkb_geometry) ;
-- 172123

select  d.* 
from public.dgurba_2018 d , public.carreaux_1km c 
where NUTS like 'FRI%' and population::int >= 300 and dgurba = 3
and ind>=25 and  st_contains(d.geom_2154, c.wkb_geometry) ;
-- 11 140

select  count(distinct lat_nat) 
from public.dgurba_2018 d , public.carreaux_1km c 
where NUTS like 'FRI%' and population::int >= 300 and dgurba = 3
and ind>=25 and st_contains( d.geom_2154, c.wkb_geometry) ;
-- 2352

-- la bonne requete poure repérer les communes "petites villes"
select  count(distinct d.gid) 
from public.dgurba_2018 d , public.carreaux_1km c 
where NUTS like 'FRI%' and dgurba = 3 and population::int >= 300
and ind>=25 and st_contains( d.geom_2154, c.wkb_geometry) ;
-- 2404 

/*
 * 1- les communes densément peuplées ;
2- les communes de densité intermédiaire ;
3- les communes peu denses ;
4- les communes très peu denses.
*/

alter table public.dgurba_2018 add column dgurba_new int ;
update public.dgurba_2018  set dgurba_new = dgurba where dgurba <=2;

update public.dgurba_2018  set dgurba_new = 3 
where gid in (
	select  distinct d.gid
	from public.dgurba_2018 d , public.carreaux_1km c 
	where NUTS like 'FRI%' and dgurba = 3 and population::int >= 300
	and ind>=25 and st_contains( d.geom_2154, c.wkb_geometry) 
); -- 2404

select * 
from public.dgurba_2018 
where dgurba_new is null and dgurba = 3
and NUTS like 'FRI%'  ;
-- 1690 qui sont très rurales  (4 les communes très peu denses.)

update public.dgurba_2018 
set dgurba_new = 4
where dgurba_new is null and dgurba = 3 and NUTS like 'FRI%'  ;
-- 1690
