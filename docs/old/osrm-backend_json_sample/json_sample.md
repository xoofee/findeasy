

## near line

curl "http://119.91.236.220:5000/route/v1/driving/103.92994335306,1.30725130889;103.92982002472499,1.307211914165?steps=true"

![alt text](01_near_line.png)

```json
{
    "code": "Ok",
    "routes": [
        {
            "geometry": "ai~FgyiyRFV",
            "legs": [
                {
                    "steps": [
                        {
                            "geometry": "ai~FgyiyRFV",
                            "maneuver": {
                                "bearing_after": 252,
                                "bearing_before": 0,
                                "location": [
                                    103.929957,
                                    1.307207
                                ],
                                "modifier": "right",
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
                                        252
                                    ],
                                    "location": [
                                        103.929957,
                                        1.307207
                                    ]
                                }
                            ],
                            "weight": 6.8,
                            "duration": 3.4,
                            "distance": 14.3
                        },
                        {
                            "geometry": "yh~FoxiyR",
                            "maneuver": {
                                "bearing_after": 0,
                                "bearing_before": 252,
                                "location": [
                                    103.929835,
                                    1.307167
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
                                        72
                                    ],
                                    "location": [
                                        103.929835,
                                        1.307167
                                    ]
                                }
                            ],
                            "weight": 0,
                            "duration": 0,
                            "distance": 0
                        }
                    ],
                    "summary": "",
                    "weight": 6.8,
                    "duration": 3.4,
                    "distance": 14.3
                }
            ],
            "weight_name": "routability",
            "weight": 6.8,
            "duration": 3.4,
            "distance": 14.3
        }
    ],
    "waypoints": [
        {
            "hint": "OwAAgEAAAIC0AQAASAAAAAAAAAAAAAAAwwy2Qml9bUEAAAAAAAAAANoAAAAkAAAAAAAAAAAAAAAEAACAZdgxBkfyEwBX2DEGc_ITAAAAjwQd6ZFO",
            "distance": 5.108682404,
            "name": "",
            "location": [
                103.929957,
                1.307207
            ]
        },
        {
            "hint": "OwAAgEAAAIBwAQAAjAAAAAAAAAAAAAAAmX2ZQj376EEAAAAAAAAAALgAAABGAAAAAAAAAAAAAAAEAACA69cxBh_yEwDc1zEGTPITAAAAjwQd6ZFO",
            "distance": 5.248428263,
            "name": "",
            "location": [
                103.929835,
                1.307167
            ]
        }
    ]
}
```