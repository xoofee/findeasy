# findeasy

- 扩展到室内定位（商铺等），野外（无信号）定位（如森林公园）
- 人群定位，广告推送

广州市经营性停车场备案信息
https://data.gz.gov.cn/dataDetail.html?sid=104877747&openStatus=1#


v0.2: speech

https://github.com/amias-samir/GraphHooperMapRouteNavigation

## TODO
- 

# deploy

```bash
sudo docker run -d -p 5000:5000 -v "/home/ubuntu/findeasy/coast:/data" --restart unless-s#pped --name osrm ghcr.io/project-osrm/osrm-backend osrm-routed --algorithm mld /data/coast.osrm

sudo docker logs osrm
```

# devolop

## dependencies

flutter pub add json_annotation
flutter pub add --dev json_serializable
flutter pub add --dev build_runner 

flutter pub add freezed_annotation
flutter pub add --dev freezed

## GPT QUESTIONS

design a backend for a frontend app. the app could get user's gps location and floor level and ask the server to respond a map of the underground parking lot map (a zip file) in the building. the building is calculated from the gps location provided by the user. the server maintain a list of builds, each with a gps location. the backend may support tens of thousands of different buildings in many cities



# misc


## app icon problem
https://stackoverflow.com/questions/79077423/flutter-launcher-icons-not-updating-properly-on-android

after generation of icon by
```flutter pub run flutter_launcher_icons:main```
remove `android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml`


# osrm-backend

## create route data

```
HNCMA-MC:/data/local/tmp/osrm $ ./osrm-extract -p car.lua coast.osm
./osrm-partition coast.osm
./osrm-customize coast.osm
./osrm-routed --algorithm mld coast.osm

/data/local/tmp/osrm/osrm-routed --algorithm mld /data/local/tmp/osrm/coast.osrm
## api

overview=false&alternatives=true&steps=true

curl "http://127.0.0.1:5000/route/v1/driving/103.92967425152,1.30707070619;103.92958660343,1.30698841679?steps=true"
curl "http://192.168.235.129:5000/route/v1/driving/103.92967425152,1.30707070619;103.92958660343,1.30698841679?steps=true"
curl "http://119.91.236.220:5000/route/v1/driving/103.92967425152,1.30707070619;103.92958660343,1.30698841679?steps=true"
curl "http://192.168.10.221:5000/route/v1/driving/103.92967425152,1.30707070619;103.92958660343,1.30698841679?steps=true"

change driving to foot or abc has no effect

```json


{
    "code": "Ok",
    "routes": [
        {
            "geometry": "mh~FkwiyR[sA`@Ib@dB",      // Polyline Encoding, see following section
            "legs": [
                {
                    "steps": [
                        {
                            "geometry": "mh~FkwiyR[sA",
                            "maneuver": {
                                "bearing_after": 72,
                                "bearing_before": 0,
                                "location": [
                                    103.929661,
                                    1.30711
                                ],
                                "type": "depart"
                            },
                            "mode": "driving",
                            "driving_side": "right",
                            "name": "",
                            "intersections": [
                                {
                                    "out": 0,
                                    "entry": [
                                        true
                                    ],
                                    "bearings": [
                                        72
                                    ],
                                    "location": [
                                        103.929661,
                                        1.30711
                                    ]
                                }
                            ],
                            "weight": 26.1,
                            "duration": 14.2,
                            "distance": 49.5
                        },
                        {
                            "geometry": "ii~F_ziyR`@I",
                            "maneuver": {
                                "bearing_after": 164,
                                "bearing_before": 71,
                                "location": [
                                    103.930084,
                                    1.307248
                                ],
                                "modifier": "right",
                                "type": "turn"
                            },
                            "mode": "driving",
                            "driving_side": "right",
                            "name": "",
                            "intersections": [
                                {
                                    "out": 0,
                                    "in": 1,
                                    "entry": [
                                        true,
                                        false,
                                        true
                                    ],
                                    "bearings": [
                                        165,
                                        255,
                                        345
                                    ],
                                    "location": [
                                        103.930084,
                                        1.307248
                                    ]
                                }
                            ],
                            "weight": 11.1,
                            "duration": 6.4,
                            "distance": 19.5
                        },
                        {
                            "geometry": "gh~FiziyRb@dB",
                            "maneuver": {
                                "bearing_after": 250,
                                "bearing_before": 164,
                                "location": [
                                    103.93013,
                                    1.307078
                                ],
                                "modifier": "right",
                                "type": "turn"
                            },
                            "mode": "driving",
                            "driving_side": "right",
                            "name": "",
                            "intersections": [
                                {
                                    "out": 1,
                                    "in": 2,
                                    "entry": [
                                        true,
                                        true,
                                        false
                                    ],
                                    "bearings": [
                                        165,
                                        255,
                                        345
                                    ],
                                    "location": [
                                        103.93013,
                                        1.307078
                                    ]
                                }
                            ],
                            "weight": 29,
                            "duration": 14.5,
                            "distance": 60.4
                        },
                        {
                            "geometry": "cg~FcwiyR",
                            "maneuver": {
                                "bearing_after": 0,
                                "bearing_before": 251,
                                "location": [
                                    103.929616,
                                    1.306903
                                ],
                                "modifier": "right",
                                "type": "arrive"
                            },
                            "mode": "driving",
                            "driving_side": "right",
                            "name": "",
                            "intersections": [
                                {
                                    "in": 0,
                                    "entry": [
                                        true
                                    ],
                                    "bearings": [
                                        71
                                    ],
                                    "location": [
                                        103.929616,
                                        1.306903
                                    ]
                                }
                            ],
                            "weight": 0,
                            "duration": 0,
                            "distance": 0
                        }
                    ],
                    "summary": "",
                    "weight": 66.2,
                    "duration": 35.1,
                    "distance": 129.4
                }
            ],
            "weight_name": "routability",
            "weight": 66.2,
            "duration": 35.1,
            "distance": 129.4
        }
    ],
    "waypoints": [
        {
            "hint": "OwAAgEAAAIAOAQAA7gAAAAAAAAAAAAAAIIZhQq_yRUIAAAAAAAAAAIcAAAB3AAAAAAAAAAAAAAAEAACAPdcxBubxEwBK1zEGv_ETAAAAjwQd6ZFO",
            "distance": 4.548637828,
            "name": "",
            "location": [
                103.929661,
                1.30711
            ]
        },
        {
            "hint": "MQAAgD0AAIDkAAAAIgEAAAAAAAAAAAAAQjM-QqSMcUIAAAAAAAAAAHIAAACRAAAAAAAAAAAAAAAEAACAENcxBhfxEwDz1jEGbPETAAAAfwQd6ZFO",
            "distance": 9.93754517,
            "name": "",
            "location": [
                103.929616,
                1.306903
            ]
        }
    ]
}

```

use flutter to parse this json. extract locations of maneuver to draw a route in flutter_map. this is used to provide navigation for user


## Google Maps polyline encoding algorithm

pip install polyline

```python
import polyline

encoded_polyline = "mh~FkwiyR[sA`@Ib@dB"
decoded_path = polyline.decode(encoded_polyline)
print(decoded_path)
# [(1.30711, 103.92966), (1.30725, 103.93008), (1.30708, 103.93013), (1.3069, 103.92962)]

import polyline

encoded_polyline = "ii~F_ziyR`@I"
decoded_path = polyline.decode(encoded_polyline)
print(decoded_path)


```

