import csv
import gzip
import time


def parse(filename):
  f = gzip.open(filename, 'r')
  entry = {}
  for l in f:
    l = l.strip()
    colonPos = l.find(':')
    if colonPos == -1:
      yield entry
      entry = {}
      continue
    eName = l[:colonPos]
    rest = l[colonPos+2:]
    entry[eName] = rest
  yield entry

def processGenderAge():
  res = {}
  ls = open("gender_age_raw.txt", 'r').readlines()
  for l in ls:
    user = {}
    fields = l.split()
    user["user/profileName"] = fields[0]
    if fields[1] != 'unknown':
      user["user/gender"] = fields[1]
    birthday = ' '.join(fields[2:])
    if birthday != 'unknown':
      try:
        unixBirthday = time.mktime(time.strptime(birthday.lower(), "%b %d, %Y"))
        today = time.mktime(time.localtime())
        ageInSeconds = today - unixBirthday
        user['user/birthdayRaw'] = birthday
        user['user/birthdayUnix'] = int(unixBirthday)
        user['user/ageInSeconds'] = int(ageInSeconds)
      except Exception as e:
        pass
    res[user['user/profileName']] = user
  return res

users = processGenderAge()
e_list = []

def parser(data_file):
  for e in parse(data_file):
    try:
      e['review/appearance'] = float(e['review/appearance'])
      e['review/taste'] = float(e['review/taste'])
      e['review/overall'] = float(e['review/overall'])
      e['review/palate'] = float(e['review/palate'])
      e['review/aroma'] = float(e['review/aroma'])
      e['review/timeUnix'] = int(e['review/time'])
      e.pop('review/time', None)
      try:
        e['beer/ABV'] = float(e['beer/ABV'])
      except Exception as q:
        e.pop('beer/ABV', None)
      e['user/profileName'] = e['review/profileName']
      e.pop('review/profileName', None)
      if users.has_key(e['user/profileName']):
        e.update(users[e['user/profileName']])
    except Exception as q:
      pass
    e_list.append(e)


def write_dict_data_to_csv_file(csv_file_path, dict_data):
  csv_file = open(csv_file_path, 'wb')
  writer = csv.writer(csv_file)

  headers = dict_data[0].keys()
  writer.writerow(headers)

  for dat in dict_data:
    line = []
    for field in headers:
      if field not in dat:
        line.append('N/A')
      else:
        line.append(dat[field])
    writer.writerow(line)
  csv_file.close()


parser('beeradvocate.txt.gz')
parser('ratebeer.txt.gz')
write_dict_data_to_csv_file('beerdata.csv', e_list)