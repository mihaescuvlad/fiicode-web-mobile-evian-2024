import torch
import numpy as np
from transformers import AutoTokenizer, AutoModel
from bson import Binary
from model import Post


tokenizer = AutoTokenizer.from_pretrained("Twitter/twhin-bert-base")
model = AutoModel.from_pretrained("Twitter/twhin-bert-base")


def process_post_data(posts, max_seq_length=512):
    post_texts = [post.title + " " + post.content for post in posts]
    inputs = tokenizer(post_texts, return_tensors="pt", padding=True, truncation=True, max_length=max_seq_length)
    return inputs


def store_embeddings(embeddings_collection, posts_collection, post_ids, embeddings):
    for post_id, embedding in zip(post_ids, embeddings):
        post_dict = Post(**posts_collection.find_one({"_id": post_id})).to_dict()

        embedding_np = embedding.detach().numpy()
        embedding_bson = Binary(embedding_np.tobytes())

        existing_document = embeddings_collection.find_one({"post_id": post_id})
        if existing_document:
            embeddings_collection.update_one(
                {"post_id": post_id}, {"$set": {"embedding": embedding_bson}}
            )
        else:
            embeddings_collection.insert_one(
                {"post_id": post_id, "post": post_dict, "embedding": embedding_bson}
            )


def get_all_embeddings(embeddings_collection):
    embeddings = []
    for document in embeddings_collection.find():
        post_data = document["post"]
        post = Post(**post_data)
        embedding_np = np.frombuffer(document["embedding"], dtype=np.float32)
        embeddings.append((post, embedding_np))
    return embeddings


def update_embeddings(embeddings_collection, posts_collection):
    all_posts = [Post(**post_dict) for post_dict in posts_collection.find()]
    processed_posts = process_post_data(all_posts)

    with torch.no_grad():
        all_outputs = model(**processed_posts)
        all_embeddings = all_outputs.last_hidden_state[:, 0, :]

    post_ids = [post.id for post in all_posts]

    store_embeddings(embeddings_collection, posts_collection, post_ids, all_embeddings)
