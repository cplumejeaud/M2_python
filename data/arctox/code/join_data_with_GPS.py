# -*- coding: utf-8 -*-
'''
Created on 21 october 2020
@author: cplumejeaud
Master 2 La Rochelle University - Geographic information
This requires the arctox database
In the exemple : it is in the savoie database, in the schema arctic

Here is the job of this TP : 
- make a join with the bird path 
- compute the total length of the path

'''

import pandas.io.sql as sql

from sqlalchemy import create_engine
from sqlalchemy import text


# Open a connection

# First you open a SSH tunnel if you have tunneling things to do
# ssh -N -L 8005:localhost:5432 -v tpm2@134.158.33.178 

engine = create_engine('postgresql://xxxx:yyyyy@localhost:8005/savoie')
engine = create_engine('postgresql://postgres:postgres@localhost:5432/savoie')

# write a query
query = "select id, timestampgps, distance_to_colony from arctic.kap_hoegh_gls order by id, timestampgps"

query = 'select count(*) from arctic.data_for_analyses where upper(gls_id) like 'MK12-12A%''



############################################################
## Run sql on the database
###########################################################


with engine.connect() as con:
    query = """select count(*) from arctic.data_for_analyses where upper(gls_id) like 'MK12-12A%'"""
    #query = 'alter table arctic.kap_hoegh_gls add column dummy int'
    #query = 'alter table arctic.kap_hoegh_gls drop column dummy'
    rs = con.execute(query)

    #Read the result if required
    for row in rs:
        print(row[0])
# This gives this error "TypeError: 'dict' object does not support indexing"
# This is due to special character % in "like 'MK12-12A%'" 
# python tries to replace % before sending the SQL query
# Solution is this : 

with engine.connect() as con:
	rs = con.execute(
		text("select count(*) from arctic.data_for_analyses where upper(gls_id) like :x"), 
		x="MK12-12A%")
	for row in rs:
		print(row)

#1. join data_for_analyses with GPS positions
query = """alter table arctic.data_for_analyses add column if not exists clean_glsid int"""
with engine.connect() as con:
    rs = con.execute(query)



query = """
	update arctic.data_for_analyses d set clean_glsid = k.clean from 
		(
		select bird_id, substring(upper(gls_id) from length('MK12-12A')+1) as clean
		from arctic.data_for_analyses
		where upper(gls_id) like :x1
		UNION
		select bird_id, substring(upper(gls_id) from length('MK18-')+1) as clean
		from arctic.data_for_analyses
		where upper(gls_id) like :x2
		UNION	
		select bird_id,  substring(upper(gls_id) from length('MK14-')+1) as clean
		from arctic.data_for_analyses
		where upper(gls_id) like :x3
		UNION
		select bird_id, substring(upper(gls_id) from length('SO-')+1) as clean
		from arctic.data_for_analyses
		where upper(gls_id) like :x4
		UNION
		select bird_id, gls_id as clean
		from arctic.data_for_analyses
		where upper(gls_id) not like 'NA' and upper(gls_id) not like :x4 and upper(gls_id) not like :x3 and upper(gls_id) not like :x2 and  upper(gls_id) not like :x1
		) as  k 
		where d.bird_id = k.bird_id
		"""

with engine.connect() as con:
	rs = con.execute(text(query), x1="MK12-12A%", x2="MK18-%", x3="MK14-%", x4="SO-%")




#2. Build the path of birds and record it in data_for_analyses
# id of kap_hoegh_gls are the clean_glsid of the GPS in data_for_analyses table

with engine.connect() as con:
    query = 'alter table arctic.data_for_analyses add column if not exists  bird_path geometry ;'
    rs = con.execute(query)
	query = 'comment on column arctic.data_for_analyses.bird_path is :x'
    rs = con.execute(text(query), x="trajectory of the bird recorded with a GLS having 150 km of resolution")

with engine.connect() as con:
	query = """update arctic.data_for_analyses d set bird_path = k.linepath
	from (
		select id, st_makeline(pointgps) as linepath
		from (select id, pointgps, timestampgps from arctic.kap_hoegh_gls order by id, timestampgps) as q 
		group by id
	) as k 
	where k.id = d.clean_glsid"""
	rs = con.execute(query)

# 3. Compute the total migration length of each bird and record it in data_for_analyses
# create a column for the length of the path

with engine.connect() as con:
    query = 'alter table arctic.data_for_analyses add column if not exists migration_length float '
    rs = con.execute(query)

with engine.connect() as con:
    query = 'update arctic.data_for_analyses set migration_length = round(st_length(bird_path, true)/ 1000)'
    rs = con.execute(query)





