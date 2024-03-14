from datetime import datetime
import os

from pymongo.collection import Collection, ReturnDocument

import flask
from flask import Flask, request, url_for, jsonify
from flask_pymongo import PyMongo
from pymongo.errors import DuplicateKeyError

from .model import Product, Post
from .objectid import PydanticObjectId
from .product_recommender import recommend_products

app = Flask(__name__)
app.config["MONGO_URI"] = os.getenv("MONGO_URI")
pymongo = PyMongo(app)

products: Collection = pymongo.db.products
users: Collection = pymongo.db.users
posts: Collection = pymongo.db.posts

@app.errorhandler(404)
def resource_not_found(e):
    return jsonify(error=str(e)), 404


@app.errorhandler(DuplicateKeyError)
def resource_not_found(e):
    return jsonify(error=f"Duplicate key error."), 400


@app.route("/products/<string:user_id>", methods=["GET"])
def list_products(user_id):
    user = users.find_one_or_404({"_id": PydanticObjectId(user_id)})
    user_allergens = user.get("allergens_ids", []) or []
    user_basket_ids = user.get("favorites", []) or []

    all_products = [Product(**doc) for doc in products.find()]
    user_basket = [product for product in all_products if product.id in user_basket_ids]

    top_recommendations = recommend_products(user_basket, all_products, user_allergens)
    
    return {
        "products": [product.id.to_json() for product in top_recommendations],
    }

@app.route("/products/page/<int:page>/<string:user_id>", methods=["GET"])
def list_products_page(page, user_id):
    user = users.find_one_or_404({"_id": PydanticObjectId(user_id)})
    user_allergens = user.get("allergens_ids", []) or []
    user_basket_ids = user.get("favorites", []) or []

    all_products = [Product(**doc) for doc in products.find({"status": "APPROVED"})]
    user_basket = [product for product in all_products if product.id in user_basket_ids]
    
    per_page = request.args.get("per_page", 10, type=int)

    top_recommendations = recommend_products(user_basket, all_products, user_allergens, len(all_products))
    total_pages = (len(top_recommendations) + per_page - 1) // per_page

    start_index = per_page * (page - 1)
    end_index = min(start_index + per_page, len(top_recommendations))

    recommendations_for_page = top_recommendations[start_index:end_index]

    return {
        "products": [product.id.to_json() for product in recommendations_for_page],
        "total_pages": total_pages
    }

@app.route("/posts", methods=["GET"])
def list_posts():
    """
    GET a list of recommended forum posts for a user.
    """
    all_posts = posts.find()

    return {
        "posts": [Post(**post).to_json() for post in all_posts],
    }