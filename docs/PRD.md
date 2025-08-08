This software is for indoor navigation, especially for car finding in parking spaces in large shopping mall, airports, large exhibition center... etc.

we support only 10 places at startup with only one software engineer for the first six months. And in next years increase to 1000 place  that have thousands of parking spaces. And increase to 100000 places world wide in the third year. We grow from a single person to a medium team in two years. Should we use difference architecture of software, deployment and hardware/cloud infrastructure, DevOps in different periods? If so recommend a involving solution for different periods of our company. Out budget is not infinite and is very tight actually.

It is composed of several systems

# Backend

## User management
- Users category
  - Customers/drivers who go to or drive their car to the place. The use the front-end app findeasy. The may report map error, and give app experience/bug feedback. They cannot edit the map.
  - Place/Building manager or staff. The upload original .dwg file of their building/parking lots for (computer-aided) indoor map generation. They modify/update the map of their building if any mismatch or updates.
  - Shop owner. May run ads in our app. Update shop info in the map.
  - Admin from our company. Admin review the dwg file uploaded or modification of map by building staff or shop infomation modification by shop owner. Admin also review ads application. The ads and payment is not urgent at startup
- Login/Logout/Registration/... service

## Map service
- use https://github.com/openstreetmap/openstreetmap-website for map data management and map elements api service. (note: if openstreetmap cannot be scaled to world wide indoor navigation, tell me and give alternative solution)
- Map upload/download/generation
  - .dwg/image/pdf automatical/semi-automatically parse (uploaded by building staff) and indoor elements recognition including route and point/polygon poi.
- Map of place (see definition below) export.
- Map cache. Place map will be cached to .osm.gz file for the front-end navigation app to download, because retrieve data from database or api is expensive. The .osm file have nodes, ways with tags. see happy_coast.osm in easyroute package. If there are better caching method, tell me. If cloud store service will be used, tell me.

- may automatically sync with 3rd-party indoor maps. (we not found supplier yet, but maybe in the future we will find thme)

## Place management.
- Definition: A place in a polygon in map.  It could be a building or building group or an bounded area.
- Connectivity: All pois in a place (inside the boundary of place) could be connected in road/path graph. If not, it should be splited to connected ones
- Levels. A place have many levels. every poi have level tag
- Place Query and map download Service. Provide place query using geoindexing. The api should receive latlon and range in meters to return a list of places with map file download path

## Data Security
  - Prevent bad guy use tools like mitmproxy to get our raw map data （.osm.gz file). The map data is our core asset. Design a method. Use encryption if necessary.

## Automatic Sound Recognition Service
To support findeasy app user interaction with voice

## OTA Service
For frontend app update. may use App market like Google Play or Xiao App Market if available.
use self-built ota server if necessary. (user cannot access the app market we support because app market is forcely specified by phone's manufacturer) 

## bluetooth/wifi signal data service
- Store/clean signals uploaded from user's phone when user report their position by POI. Ths is a crowd-source. Then in the feature the data could be used for localization which will be more accurate than user's poi report.

# findeasy (indoor navigation app)

## Map

- get map (.osm.gz, encrypted, for a place) from backend using user's location. If no building found or match errorously, let the user to report or connect our customer manager. He may use the app to feed back or call us directly.
- indoor map rendering. 2d for now and 3d in the future. May turn on or turn off the outdoor map as base layer.
- show poi and road/ways. Show parking space name (like B1-103, E124) when zoom factor exceed certain value. Show less poi names (including shops, ...) if screen cannot hold

## Navigation

### Localization

- support localization by user report POI near he
- support compass / imu to rotate the map to align with the actual scenario. Also use compass/imu to detect possible turning at crosses
- may integrate walk step numbers to estimate how long the user has go
- May support bluetooth/wifi localization in the future (not urgent). May collect radio signals when user report POI and store on server. When enough data is acquired, bluetooth/wifi localization is possible. This may require our backend have corresponding feature or service.

### Routing
Note: we rely on user's reporting poi to update and check user's location, and give new instruction if he is approaching crosses.
- use easyroute to generate shorted path and instructions. Note: indoor routing is easier than outdoor, and we use easyroute directly on mobile device, not as cloud service, in order to save cloud resources.
- use deviation detection from easyroute to check if user deviated (by his newly report poi, or bluetooth accurate location if supported). If deviated, replan the path.

The routing instructions returned by easyroute maybe like:

1. At C165 on the left - Turn left. then, go for 22m
2. At C159 on the left - Turn right. then, go for 30m
3. At C102 on the right - Turn right. then, go for 15m
4. At C101 on the right - Turn left. then, go for 9m
5. At C14 on the left - Take the elevator - E1 from level 0 to level -1
6. At K25 on the right - Turn sharp right. then, go for 7m
7. At K137 on the right - Turn right. then, go for 11m
8. At K25 on the right - Turn left. then, go for 112m
9. At J199 on the right - Turn right. then, go for 14m
10. At J225 on the left - Turn right. then, go for 115m
11. At I158 on the left - You have reached your destination. then, go for 3m
End: I172 (amenity:parking_space) at Level -1

During the navigation, the parking lot / poi will be highlighted at cross for the user's convienence.

###  Voice Assistant
- ASR assistance
  - Support ASR (automatic sound recognition) and text input to specify start and end poi
  - Recognize voice input and show the recognized text on screen, e.g.,
    - "My car is at E103"
    - "navigate to A135"
    - "I am at C102"
  - Give feed back if the ASR understand the user's voice input, e.g.,
    - "Ok, I remember, your car parked at F117"
    - "Sorry, D113 is not found"
  - may integrated with phone's voice assistant like siri in iOS. or Xiaoyi in Huawei, when use an centralized voice input/natural language interaction for all apps on the phone 
  - support both 3rd-party ASR service or self-deployed cloud ASR service or offline mode (may use xiaomi shepra). Support offline mode downloaded in background if user agree.
- TTS using native tts to speek navigation instructions. It is like a smart assistant. Could be waken by voice or manual operation. Could automatically sleep if continuous no interaction. The TTS should avoid voice detection by ASR. (ASR should detect human voice not the TTS voice)
  - support language configuration or get from phone system. Then recognize/tts speek/download offline model of the language. This app should support all lanuages in the world.

Note: the app could run completely without the voice assistant. User could use text input or tap on the poi to report poi or select/input destination. The voice assistant is just used to help the user, not replace the traditional interaction


### integrate 3rd-party car finding system
The building may already have camera-based car finding system (install many camera in the parking lot). Out app may integrated with them. The user may forget where he park the car, we can call the interface of 3rd-party system to get the parking lot number by the user's car plate number. Then navigate the user to his car.


## configuration
save and load configuration on start.

## user login/management
- Do not require login at startup. only require for user-specific feature (like app advice sumbit and get reply from admin in the backend)
- Support Single Sign-On by weixin or google. Support one-key login with phone number (do not need for user input the number). Support easy one-time verification code login by sms(automatically register first if not registered yet)
- we may make statistics on user's usage
- user points system like coupon. If he invite registration of a friend he may receive points. The points could be used for payment in the feature, though this app is free for now. This feature is not urgent.


## splash screen
could be configured to disabled for debugging/internal test purpose. When test internally always see the splash is a waste of time

## map data encryption
save logic with server and transfer. Data in mobile app storage folder should be encrpted in case of data inception. Only decrypt when app is running and loading the data

## Payment
- We may let the user give some little money to us if he successfully find his car / shop / other poi. It is free for now. May use Weixin/paypal/... 
- ads fees payment for shop owners
this feature is not urgent

## map error / advice feedback by user
If user found some error, or have some good experience optimization advice, or encounter some bugs of our app, he may give feed back in the app. The admin could review and reply, which the user could see.

## user behavior statistic
The product manager want to know if user like some feature or never use it. May use 3rd party service (like Google Analytics for web) or self-developped service.

## OTA
- new version check and user remind (with a red dot if not forced update)

## Help
- User can view documents/video tutorial for this app.

# Admin portal (web)

## Map Generation
Like JOSM/OSM iD for 2d and 3d map editor.
Route generation and check.
may call easyroute to check connectivity or to validate the map created.
Polygon poi check whether the first two point/nodes is the front face of the POI. (The side which parking lot numer is painted on the ground, or the door of a shop)
Refer to the map service above.

## Data Center
A web page to show statistics like users, places with one screen. This is mostly used for demo show or roadshow. May show how many places/buildings we support in a global map. Show register users and daily or monthly active users. How many times user request for route in recent days (with a curve). What if the most visited building/shops. It may use the data collected from app. see "user behavior statistic above".

# Merchant Portal (mobile/web)

## Map Generation and check.
same as the admin portal. But with limited privillege. e.g., The building staff or shop owner can only see his building/place. 

- Map check
Let the build staff check the parking lots and shop names and shapes. He may walk round to visit all pois, if he see poi is right, he can mark the poi as "checked" on the app. Because the map made by man or recognized by software can have mistakes. We want the building staff check for the first time when the indoor navitaion for his building is going to be online.

- Map update
may disable or enable some poi/road or passage. 

## Ads
shop owner may run ads on the findeasy frontend app.
He could pay on the merchant portal
He may see how many users click the ads for his shop

# DevOps
If this software is developed by a single person at first at a startup company. And gradually more software engineers comes in. How should the develop-deplopy and operations & maintainance be done. Any CI/CD practice? When to bring in it?

# cloud platform
Should we use K8s and docker-style deployment? If should, when to use


give all requirements above, make an full progressive solution that is good enough for now and flexible enough to scale. Make the folder structure for me for all relevant components/subsystem/modules/deploy roadmap orscripts/.... You should act like an architect or CTO for me. Because I am a freshman.

also give detailed arch and folder structure of the flutter findeasy app 
