# Names: Emilio Luz-Ricca and Clare Heinbaugh
# Date: 2/27/2021

# To update the deployed server, run the following:
# gcloud builds submit --tag gcr.io/vthacks2021/backend
# gcloud beta run deploy --image gcr.io/vthacks2021/backend
# firebase deploy

from flask import Flask, render_template, make_response
import os
import time

from flask import request, url_for
from flask_api import FlaskAPI, status, exceptions

import requests

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

from datetime import datetime

#Utility function - from StackOverflow!
def strNumbers(s):
    return sum([char.isdigit() for char in s])

#Pulling in vision credentials
with open('api_key.txt', 'r') as f:
    key = f.read().strip()

#Set up DB stuff
cred = credentials.Certificate('vthacks2021-firebase-adminsdk-9puvj-2dfee3c8ba.json')
firebase_admin.initialize_app(cred, {'storageBucket' : 'VTHacks2021.appspot.com'})
db = firestore.client()

#Bulding the Flask API
app = FlaskAPI(__name__)

# Example request: {"url" : "https://firebasestorage.googleapis.com/v0/b/vthacks2021.appspot.com/o/IMG_5071.jpg?alt=media&token=53fa5860-e725-40af-b0b4-d87e5aae94ae", "lat" : 150, "lon" : 100}

#POST request with URL and lat/lon
@app.route('/', methods = ['POST'])
def process_request():
    all_passed = request.data #comes in as a dictionary... expecting keys "url", "lat", "lon"

    #Making the call to vision and processing response
    API_URL = 'https://vision.googleapis.com/v1/images:annotate?key=' + str(key)

    build_req = {
      'requests':[
        {
          'image':{
            'source':{
              'imageUri':
                all_passed['url']
            }
          },
          'features':[
            {
              'type':'DOCUMENT_TEXT_DETECTION'
            }
          ]
        }
      ]
    }

    response = requests.post(API_URL, json = build_req)
    resp_content = response.json()

    #  pulling out the serial number
    all_text = resp_content['responses'][0]['textAnnotations'][0]['description']
    right_length = [w for w in all_text.replace(' ', '').split('\n') if len(w) == 11] #TODO: replace w/11 characters for our bills!

    en_words = ['washington', 'jefferson', 'hamilton', 'jackson', 'lincoln', 'abraham', 'andrew', 'thomas', 'george', 'franklin', 'benjamin',
                'federal', 'reserve', 'note', 'twenty', 'united', 'states', 'of', 'america', 'the', 'secretary', 'treasury', 'series',
                'dollars', 'dollar', 'this', 'legal', 'is', 'tender', 'for', 'all', 'debts', 'public', 'and', 'private', 'system', 'bank',
                'five', 'one', 'ten', 'hundred', 'thousand', 'steven']
    potential_serials = [w for w in right_length if not w.lower() in en_words]
    potential_serials = [ser for ser in potential_serials if strNumbers(ser) >= 2]

    serial = None
    try:
        serial = potential_serials[0]
    except IndexError:
        return {'status' : 'BAD'}

    #Interacting w/Firebase
    users_ref = db.collection(u'dollars')
    docs = users_ref.stream()

    #  grabbing the data, if it exists...
    new_serial = True
    for d in docs:
        if d.id.strip() == serial:
            new_serial = False
            d = d.to_dict()
            all_lats = d['latitudes']
            all_longs = d['longitudes']
            # all_times = d['timestamps']

    if new_serial:
        all_lats = []
        all_longs = []
    # new_time = datetime.now()

    all_lats.append(all_passed['lat'])
    all_longs.append(all_passed['lon'])
    # all_times.append(new_time)

    #  updating records in DB
    doc_ref = db.collection(u'dollars').document(serial)
    doc_ref.set({'latitudes' : all_lats, 'longitudes' : all_longs})

    return {'status' : 'GOOD', 'firstTime' : new_serial, 'serial' : serial, 'latitudes' : all_lats, 'longitudes' : all_longs}

def format_server_time():
  server_time = time.localtime()
  return time.strftime("%I:%M:%S %p", server_time)

@app.route('/', methods = ['GET'])
def index():
    context = {'server_time': format_server_time()}
    # 1
    template = render_template('index.html', context=context)
    # 2
    response = make_response(template)
    # 3
    response.headers['Cache-Control'] = 'public, max-age=300, s-maxage=600'
    return response

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
