from fastapi.encoders import jsonable_encoder

from pydantic import BaseModel, Field
from typing import List, Optional

from .objectid import PydanticObjectId

class User(BaseModel):
    id: Optional[PydanticObjectId] = Field(None, alias="_id")
    allergens_ids: List[str]
    favorites: List[PydanticObjectId]

class Product(BaseModel):
    id: Optional[PydanticObjectId] = Field(None, alias="_id")
    name: str
    brand: str
    allergens: List[str]
    ingredients: Optional[List[str]]
    calories: float
    fat: float
    carbohydrates: float
    protein: float
    rating: int

    def to_json(self):
        return jsonable_encoder(self, exclude_none=True)

    def to_bson(self):
        data = self.dict(by_alias=True, exclude_none=True)
        if data.get("_id") is None:
            data.pop("_id", None)
        return data
    
class UserForum(BaseModel):
    id: Optional[PydanticObjectId] = Field(None, alias="_id")
    following_ids: List[PydanticObjectId]

class Post(BaseModel):
    id: Optional[PydanticObjectId] = Field(None, alias="_id")
    author_id: PydanticObjectId
    title: str
    content: str
    hashtags: List[str]
    response_to_id: Optional[PydanticObjectId]

    def to_json(self):
        return jsonable_encoder(self, exclude_none=True)

    def to_bson(self):
        data = self.dict(by_alias=True, exclude_none=True)
        if data.get("_id") is None:
            data.pop("_id", None)
        return data