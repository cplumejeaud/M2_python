--  sudo -u postgres psql -U postgres -c "CREATE database jason3 encoding UTF8"


create extension postgis ;


create table track (
	identifiant text not NULL,
	indice text not NULL,
	numero int not NULL,
	date_min timestamp,
	date_max timestamp,
	boundingbox geometry
);

-- 
-- geometry ST_MakeEnvelope(ds.longitude.min(), float ymin, float xmax, float ymax, integer srid=unknown);

/*
insert into track (identifiant, indice, numero, date_min, date_max, boundingbox) 
values ('JA3_GPN_2PfP310_070_20220730_030014_20220730_035627', '070', '070'::int, '2022-07-30T03:00:15.454626048', '2022-07-30T03:56:27.083136128', ST_MakeEnvelope(0.001686, -66.145616, 359.999847, 66.145103, 4326) );
*/

truncate track CASCADE;

alter table track add constraint pk_track primary key  (identifiant); -- contient l'id du cycle

CREATE INDEX idx_track 
ON public.track
using btree(numero);

CREATE INDEX idx_track_spatial 
ON public.track
USING gist (boundingbox);

create table pointtime (
	trackid text,
	ptid serial,
	long float,
	lat float,
	datetime timestamp,
	point geometry);

-- définir la clé primaire de pointtime
alter table pointtime add constraint pk_ptid primary key (ptid);
-- clé étrangère des points vers la track
alter table pointtime add constraint fk_pointtime_track foreign key  (trackid) references track (identifiant) on delete cascade;
	

create table varvalues (
	ptid integer,
	varid integer,
	value float
	);
	
create table variable (
	varid serial primary key,
	varname text,
	varunit text,
	commentaires text);

alter table variable rename varname to  standard_name;
alter table variable add column longname text;
alter table variable add column varname text;

-- insert into variable (varname, varunit, commentaires) values (,,);
truncate table variable CASCADE;
alter table varvalues add constraint fk_varvalues_pointtime foreign key  (ptid) references pointtime (ptid) on delete cascade;
alter table varvalues add constraint fk_varvalues_variable foreign key  (varid) references variable (varid) on delete cascade;

