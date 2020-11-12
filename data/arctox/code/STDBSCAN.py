# import from git : https://github.com/gitAtila/ST-DBSCAN
#http://darribas.org/gds_scipy16/ipynb_md/07_spatial_clustering.html

import math
from datetime import timedelta
from geopy.distance import great_circle
"""
INPUTS:
    df={o1,o2,...,on} Set of objects
    spatial_threshold = Maximum geographical coordinate (spatial) distance value
    temporal_threshold = Maximum non-spatial distance value
    min_neighbors = Minimun number of points within Eps1 and Eps2 distance
OUTPUT:
    C = {c1,c2,...,ck} Set of clusters
"""
def ST_DBSCAN(df, spatial_threshold, temporal_threshold, min_neighbors):
    cluster_label = 0
    NOISE = -1
    UNMARKED = 777777
    stack = []

    # initialize each point with unmarked
    df['cluster'] = UNMARKED
    
    # for each point in database
    for index, point in df.iterrows():
        if df.loc[index]['cluster'] == UNMARKED:
            neighborhood = retrieve_neighbors(index, df, spatial_threshold, temporal_threshold)
            
            if len(neighborhood) < min_neighbors:
                df.at[index, 'cluster'] = NOISE

            else: # found a core point
                cluster_label = cluster_label + 1
                df.at[index, 'cluster'] = cluster_label# assign a label to core point

                for neig_index in neighborhood: # assign core's label to its neighborhood
                    df.at[neig_index, 'cluster'] = cluster_label
                    stack.append(neig_index) # append neighborhood to stack
                
                while len(stack) > 0: # find new neighbors from core point neighborhood
                    current_point_index = stack.pop()
                    new_neighborhood = retrieve_neighbors(current_point_index, df, spatial_threshold, temporal_threshold)
                    
                    if len(new_neighborhood) >= min_neighbors: # current_point is a new core
                        for neig_index in new_neighborhood:
                            neig_cluster = df.loc[neig_index]['cluster']
                            if (neig_cluster != NOISE) & (neig_cluster == UNMARKED): 
                                # TODO: verify cluster average before add new point
                                df.at[neig_index, 'cluster'] = cluster_label
                                stack.append(neig_index)
    return df


def retrieve_neighbors(index_center, df, spatial_threshold, temporal_threshold):
    neigborhood = []

    center_point = df.loc[index_center]

    # filter by time 
    min_time = center_point['date_time'] - timedelta(minutes = temporal_threshold)
    max_time = center_point['date_time'] + timedelta(minutes = temporal_threshold)
    df = df[(df['date_time'] >= min_time) & (df['date_time'] <= max_time)]

    # filter by distance
    for index, point in df.iterrows():
        if index != index_center:
            distance = great_circle((center_point['latitude'], center_point['longitude']), (point['latitude'], point['longitude'])).meters
            if distance <= spatial_threshold:
                neigborhood.append(index)

    return neigborhood

if __name__ == "__main__":
    pass

    #csv_path = argv[1]
    # Select points that are in the cluster having the longest duration per bird and where cid is not null

    ## Adapt 
    query  = """    
    select c.id, c.cid, c.duration, g.pkid, g.smooth_lat as latitude, g.smooth_long as longitude, g.timestampgps as date_time
    from 
	(select c.id, max(duration) as m
	from arctic.spatial_cluster c 
	where duration is not null
	group by c.id) as  k , 
	arctic.spatial_cluster c,
	arctic.kap_hoegh_gls g  
	where c.id = k.id and c.duration = k.m and g.pkid = ANY  (c.pkids_in_cluster) 

    """
    engine = create_engine('postgresql://maliha:malihaM2@localhost:5432/savoie')
    df_table = sql.read_sql_query(query, engine)

    # df_table must have the columns: 'latitude', 'longitude' and 'date_time'
    #df_table = pd.read_csv(csv_path)
    print(df_table.columns)
    print(df_table.shape)

    spatial_threshold = 350000 # meters
    temporal_threshold = ??? # minutes
    min_neighbors = 5
    df_clustering = ST_DBSCAN(df_table, spatial_threshold, temporal_threshold, min_neighbors)
    print(df_clustering)