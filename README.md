# PixSpy
PixSpy tracks open of document with time and geo location taken from IP address.


- Tracks IP
- Tracks Geolocation from IP
- Keeps History
- If image doesn't exist, creates one.
- If id isn't present, it will generate randomly.

== Usage

REST Based

Source friendly
http://localhost:3000/x.gif
http://localhost:3000/create/ffff.gif
http://localhost:3000/list/x.gif

REST Friendly
http://localhost:3000/x.gif POST to create new image with id X
http://localhost:3000/x.gif GET to display image. (If doesn't exist already, it will create one)
http://localhost:3000/list/x.gif to list history of hits.


==Future

- Add same ip sleep period for N seconds.
- Add Basic Auth for listing history.


== Sample data for history

```
{  
   "geo":{  
      "range":[  
         2057411584,
         2057412095
      ],
      "country":"IN",
      "region":"07",
      "city":"Delhi",
      "ll":[  
         28.6667,
         77.2167
      ],
      "metro":0
   },
   "ip":"122.161.157.158",
   "id":"x",
   "lastHit":"2015-08-04T22:39:07.195Z",
   "updated_at":"2015-08-04T22:39:07.195Z",
   "created_at":"2015-08-04T22:38:59.715Z",
   "hitCount":1,
   "hitHistory":[  
      {  
         "ip":"122.161.157.158",
         "geo":{  
            "range":[  
               2057411584,
               2057412095
            ],
            "country":"IN",
            "region":"07",
            "city":"Delhi",
            "ll":[  
               28.6667,
               77.2167
            ],
            "metro":0
         }
      }
   ]
}
```
