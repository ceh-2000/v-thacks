#STUFF:
#  -Use folium for building interactive maps and outputting HTML
#  -Use edit distance to compare new serial nums to ones in firebase... more permissive to make it more consistent!

import requests
# from nltk.corpus import words

with open('api_key.txt', 'r') as f:
    key = f.read().strip()

# print(key)

img_URL = 'https://firebasestorage.googleapis.com/v0/b/vthacks2021.appspot.com/o/IMG_5071.jpg?alt=media&token=53fa5860-e725-40af-b0b4-d87e5aae94ae'
API_URL = 'https://vision.googleapis.com/v1/images:annotate?key=' + str(key)

# print(API_URL)

build_req = {
  'requests':[
    {
      'image':{
        'source':{
          'imageUri':
            img_URL
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
all_text = resp_content['responses'][0]['textAnnotations'][0]['description']

# print(all_text)

#pulling out the serial number
right_length = [w for w in all_text.replace(' ', '').split('\n') if len(w) == 11] #TODO: replace w/11 characters for our bills!

# en_words = set(words.words() + ['washington', 'jefferson', 'hamilton', 'jackson', 'lincoln', 'abraham', 'andrew', 'thomas', 'george', 'franklin', 'benjamin'])
en_words = ['washington', 'jefferson', 'hamilton', 'jackson', 'lincoln', 'abraham', 'andrew', 'thomas', 'george', 'franklin', 'benjamin',
            'federal', 'reserve', 'note', 'twenty', 'united', 'states', 'of', 'america', 'the', 'secretary', 'treasury', 'series',
            'dollars', 'dollar', 'this', 'legal', 'is', 'tender', 'for', 'all', 'debts', 'public', 'and', 'private', 'system', 'bank',
            'five', 'one', 'ten', 'hundred', 'thousand', 'steven']
potential_serials = [w for w in right_length if not w.lower() in en_words]

serial = None
try:
    serial = potential_serials[0]
except IndexError:
    print('Huh... we didn\'t get any serial numbers')

if serial is not None:
    print(serial)
