#!/usr/bin/env python
"""
 SUBSCRIBE
           TO
              PEWDIEPIE
"""

import sys
import urllib.request
import json


def getsubcount(id, key):
    data = urllib.request.urlopen(
        'https://www.googleapis.com/youtube/v3/channels?part=statistics&id=' +
        id + '&key=' + key).read()
    return json.loads(
                data.decode('utf-8')
            )['items'][0]['statistics']['subscriberCount']


def main():
    key = 'AIzaSyBR7ZQmh02ETze1hjNS7rFYsSJSBYoUsvY'
    pdp = int(getsubcount('UC-lHJZR3Gqxm24_Vd_AJ5Yw', key))
    tser = int(getsubcount('UCq-Fj5jknLsUf-MWSy4_brA', key))

    delta = pdp - tser

    if delta > 0:
        print("PewDiePie subgap: " + str(delta))
    else:
        print(f"The age of actual creators is over. ({delta})")


if __name__ == '__main__':
    sys.exit(main())
