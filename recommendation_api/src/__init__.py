import os
import threading
import time
import schedule
from pymongo.collection import Collection

from flask import Flask, request, url_for, jsonify
from flask_pymongo import PyMongo
from pymongo.errors import DuplicateKeyError

from .model import Product, Post, UserForum
from .objectid import PydanticObjectId

from .product_recommender import recommend_products

from .posts_embeddings import update_embeddings
from .posts_recommender import recommend_posts

app = Flask(__name__)
app.config["MONGO_URI"] = os.getenv("MONGO_URI")
pymongo = PyMongo(app)

products: Collection = pymongo.db.products
users: Collection = pymongo.db.users

posts: Collection = pymongo.db.posts
embeddings: Collection = pymongo.db.embeddings
ratings: Collection = pymongo.db.ratings

def run_in_background(interval=1):
    cease_continuous_run = threading.Event()

    class ScheduleThread(threading.Thread):
        @classmethod
        def run(cls):
            while not cease_continuous_run.is_set():
                schedule.run_pending()
                time.sleep(interval)

    continuous_thread = ScheduleThread()
    continuous_thread.start()
    return cease_continuous_run

def update_embeddings_job():
    update_embeddings(embeddings, posts)

schedule.every().day.at("00:00").do(update_embeddings_job)

run_in_background()

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

    all_products = [Product(**doc) for doc in products.find()]
    user_basket = [product for product in all_products if product.id in user_basket_ids]
    
    per_page = 9

    top_recommendations = recommend_products(user_basket, all_products, user_allergens, len(all_products))
    total_pages = (len(top_recommendations) + per_page - 1) // per_page

    start_index = per_page * (page - 1)
    end_index = min(start_index + per_page, len(top_recommendations))

    recommendations_for_page = top_recommendations[start_index:end_index]

    links = {
        "self": {"href": url_for(".list_products_page", page=page, user_id=user_id, _external=True)},
        "last": {"href": url_for(".list_products_page", page=total_pages, user_id=user_id, _external=True)}
    }
    if page > 1:
        links["prev"] = {"href": url_for(".list_products_page", page=page - 1, user_id=user_id, _external=True)}
    if page < total_pages:
        links["next"] = {"href": url_for(".list_products_page", page=page + 1, user_id=user_id, _external=True)}

    return {
        "products": [product.id.to_json() for product in recommendations_for_page],
        "_links": links
    }

@app.route("/posts/<string:user_id>", methods=["GET"])
def list_posts(user_id):
    user = users.find_one_or_404({"_id": PydanticObjectId(user_id)})
    current_user_forum = UserForum(_id=user["_id"], following_ids=user["following_ids"])

    pipeline = [
        {"$match": {"user_id": current_user_forum.id, "vote": {"$in": ["up_vote", "down_vote"]}}},
        {"$group": {"_id": "$vote", "post_ids": {"$push": "$post_id"}}}
    ]

    results = list(ratings.aggregate(pipeline))

    liked_posts = results[0]["post_ids"] if results else []
    disliked_posts = results[1]["post_ids"] if len(results) > 1 else []

    top_recommendations = recommend_posts(liked_posts, disliked_posts, current_user_forum.following_ids, embeddings)
    
    return {
        "posts": [post.id.to_json() for post in top_recommendations],
    }

@app.route("/posts/page/<int:page>/<string:user_id>", methods=["GET"])
def list_posts_page(page, user_id):
    user = users.find_one_or_404({"_id": PydanticObjectId(user_id)})
    current_user_forum = UserForum(_id=user["_id"], following_ids=user["following_ids"])

    pipeline = [
        {"$match": {"user_id": current_user_forum.id, "vote": {"$in": ["up_vote", "down_vote"]}}},
        {"$group": {"_id": "$vote", "post_ids": {"$push": "$post_id"}}}
    ]

    results = list(ratings.aggregate(pipeline))

    liked_posts = results[0]["post_ids"] if results else []
    disliked_posts = results[1]["post_ids"] if len(results) > 1 else []
    
    per_page = 9

    top_recommendations = recommend_posts(liked_posts, disliked_posts, current_user_forum.following_ids, embeddings)

    start_index = per_page * (page - 1)
    end_index = min(start_index + per_page, len(top_recommendations))

    recommendations_for_page = top_recommendations[start_index:end_index]

    return {
        "posts": [post.id.to_json() for post in recommendations_for_page],
    }
