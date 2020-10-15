#!/usr/bin/python3
# -*-coding:UTF-8 -*

'''
Created on 12 october 2020
@author: cplumejeaud, 

Used to push arctox data on the Web
'''

from flask import Flask, jsonify, abort, render_template,url_for,request, make_response
from flask_cors import CORS, cross_origin

from flask_caching import Cache
import csv
import json
import io
import os

#import flask_ext 
#import flask_excel as excel
#import pyexcel as pe

import pandas as pd



#APP_ROOT = os.path.dirname(os.path.abspath(__file__))   # refers to application_top
#APP_STATIC = os.path.join(APP_ROOT, 'static')
#APP_DATA = os.path.join(APP_STATIC, 'data')

app = Flask(__name__)
#CORS(app)

    
port = '80'

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/alldata/')   
def myfunction_that_crashes_data():
    """
    mes commentaires
    """
    df = pd.read_excel("C:\\Travail\\CNRS_mycore\\Cours\\Cours_M2_python\\Projet_Arctox\\data for analyses_2010_2011_analyses.xls", 
                        sheet_name="data for analyses_2010_2011_ana")
    
    ## Check header
    list(df)
    df.columns

    '''Index(['Year', 'Bird_ID', 'GLS_ID', 'Sex', 'Date', 'Nest', 'Nest_content',
       'Capture_method', 'Headbill', 'Culmen', 'Wing', 'Right_tarsus', 'Mass',
       'Index_body_condition', 'Muscle_Pectoral', 'Score_Personal', 'Long_Egg',
       'Long_Egg_cm', 'Larg_Egg', 'Larg_Egg_cm', 'Vol_egg', 'Arrival_date',
       'Arrival_date_num', 'Arrival_date_propre', 'Arrival_date_propre_num',
       'date_enter_nest', 'date_enter_nest_num', 'Hatch_date',
       'Hatch_date_num', 'weigh_hatching', 'Hatching_success',
       'Chick_mass_gain_(g/d)_1st_15d', 'pente_chick_growth_1-15d',
       'N_SIA_Blood', 'N_SIA_head_Feather', 'C_SIA_Blood',
       'C_SIA_head_Feather', 'Chick_sex', 'Cortico', 'Hg_HF', 'Hg_blood',
       'Season_Hg_Blood', 'Hg_BF', 'BF_side', 'Long_Median_15Oct_20Fev',
       'Lat_Median_15Oct_20Fev', 'Long_Median_DecJan', 'Lat_Median_DecJan',
       'Long_Median_Dec_20Fev', 'Lat_Median_Dec_20Fev', 'd_PL_15Oct_20Fev',
       'd_PL_DecJan', 'd_PL_1Dec_20Fev', 'Max_d_col__Dec_Jan',
       'Max_d_col__15Oct_20Fev', 'PL_Lat', 'PL_Long'],
      dtype='object')
      '''

    '''
    jsonx = df.to_json(orient='records')
    type(jsonx)
    print(jsonx)
    import json 
    json.dumps(jsonx)
    '''

    json_str = json.dumps(df.to_json(orient='records'))
    return json.loads(json_str)

if __name__ == '__main__':
    app.run(debug=True,port=port,threaded=True)  

