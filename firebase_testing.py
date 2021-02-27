import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

from datetime import datetime

#Set up DB stuff
cred = credentials.Certificate('vthacks2021-firebase-adminsdk-9puvj-2dfee3c8ba.json')
firebase_admin.initialize_app(cred, {'storageBucket' : 'VTHacks2021.appspot.com'})
db = firestore.client()

#Trying to grab stuff
users_ref = db.collection(u'dollars')
docs = users_ref.stream()

target_serial = 'MH47102243B'

for d in docs:
    # print(d.id)
    if d.id.strip() == target_serial:
        d = d.to_dict()
        all_lats = d['latitudes']
        all_longs = d['longitudes']
        all_times = d['timestamps']

        print(all_lats, all_longs, all_times, sep = '\n')

# print(type(all_times[0]))

#Adding new stuff
new_lat = 12
new_long = 32
new_time = datetime.now()

all_lats.append(new_lat)
all_longs.append(new_long)
all_times.append(new_time)

doc_ref = db.collection(u'dollars').document(target_serial)
doc_ref.set({'latitudes' : all_lats,
             'longitudes' : all_longs,
             'timestamps' : all_times})
