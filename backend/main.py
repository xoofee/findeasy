'''
uvicorn main:app --reload --host 0.0.0.0  --port 5001
'''

import os
from typing import Optional, Annotated
from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, Field, BeforeValidator
from pymongo import MongoClient
from bson import ObjectId
from dotenv import load_dotenv
import logging
from typing import Literal

logger = logging.getLogger('uvicorn.error')
logger.setLevel(logging.DEBUG)

# Load environment variables from .env
load_dotenv()

# MongoDB connection
client = MongoClient(os.getenv("MONGODB_URI", 'mongodb://localhost:27017'))
db = client.findeasy
places_collection = db.places

# FastAPI application
app = FastAPI(
    openapi_url="/eefoox/openapi.json",
    docs_url="/eefoox/docs",  # You can change the docs URL here
    redoc_url="/eefoox/redoc"  # You can change the ReDoc URL here
)

# _id id naming problem: see https://stackoverflow.com/a/77727741
PyObjectId = Annotated[str, BeforeValidator(str)]

# Pydantic model for input validation
class Location(BaseModel):
    type: Literal["Point"]
    coordinates: tuple[float, float]  # Exactly two floats

class Place(BaseModel):
    name: str
    address: str
    location: Location
    parking_zones: dict[str, str]    # 'B2': 'B1' if B2 same as B1

class PlaceInDB(Place):
    # directly use _id results in json not have _id, because pydantic does not 
    # serialize member with underscore prefix
    id: Optional[PyObjectId] = Field(alias="_id", default=None)

@app.post("/places/", response_model=PlaceInDB)
async def create_place(place: Place):
    raise HTTPException(status_code=405, detail="CREATE method is not allowed")

    # Insert the place into MongoDB
    place_data = place.dict()
    result = places_collection.insert_one(place_data)
    
    # Return the inserted place with its generated ID
    place_data["_id"] = str(result.inserted_id)
    return place_data

@app.delete("/places/{place_id}", response_description="Delete a Place")
async def delete_place(place_id: str):
    raise HTTPException(status_code=405, detail="DELETE method is not allowed")

    # Check if the ID is a valid ObjectId
    if not ObjectId.is_valid(place_id):
        raise HTTPException(status_code=400, detail="Invalid Place ID")

    # Attempt to delete the place
    delete_result = places_collection.delete_one({"_id": ObjectId(place_id)})

    # Check if the place was deleted
    if delete_result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Place not found")

    return {"message": f"Place with ID {place_id} has been deleted successfully"}

@app.get("/places/", response_model=list[PlaceInDB])
async def get_all_places():
    places = places_collection.find()
    # for place in places:
    #     logger.debug(place)
    return [PlaceInDB(**place) for place in places]

@app.get("/places/{place_id}", response_model=PlaceInDB)
async def get_place(place_id: str):
    place = places_collection.find_one({"_id": ObjectId(place_id)})
    if place is None:
        raise HTTPException(status_code=404, detail="Place not found")
    return PlaceInDB(**place)

'''
番禺天河城坐标
http://119.91.236.220:5001/places_near?lat=23.0061835&lon=113.3431710&max_distance=500
'''
@app.get("/places_near", response_model=list[PlaceInDB])
async def get_nearby_places(lat: float, lon: float, max_distance: float = 500.0):
    places = places_collection.find({
        "location": {
            "$nearSphere": {
                "$geometry": {
                    "type": "Point",
                    "coordinates": [lon, lat]
                },
                "$maxDistance": max_distance  # In meters
            }
        }
    })
    return [PlaceInDB(**place) for place in places]

# TODO: (per user) rate limit
@app.get("/places/{place_id}/{parking_zone}/download")
async def generate_download_url(place_id: str, parking_zone: str):
    # Check if the place exists and if the parking zone is valid
    place = places_collection.find_one({"_id": ObjectId(place_id)})
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")

    parking_zones = place.get("parking_zones", {})
    if parking_zone not in parking_zones:
        raise HTTPException(status_code=400, detail="Parking zone not found")
    
    # Construct the download URL
    download_url = f"http://{os.getenv('HOST_IP', 'xoofee.top')}/d/findeasy/places/{place_id}/{parking_zones[parking_zone]}.zip"
    # return {"download_url": download_url}
    return RedirectResponse(url=download_url)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=os.getenv("HOST", "0.0.0.0"), port=int(os.getenv("PORT", 5001)))

