import torch
from .posts_embeddings import get_all_embeddings


def recommend_posts(liked_posts, disliked_posts, following_ids, embeddings_collection):
    all_embeddings = get_all_embeddings(embeddings_collection)
    all_embeddings = [
        (post_id, embedding)
        for post_id, embedding in all_embeddings
        if post_id.response_to_id is None
    ]

    liked_embeddings = [
        (post_id, embedding)
        for post_id, embedding in all_embeddings
        if post_id in liked_posts
    ]
    disliked_embeddings = [
        (post_id, embedding)
        for post_id, embedding in all_embeddings
        if post_id in disliked_posts
    ]

    recommendation_scores = torch.zeros(len(all_embeddings))

    for i, (post, post_embedding) in enumerate(all_embeddings):
        if post.response_to_id is not None:
            continue

        if post.author_id in following_ids:
            recommendation_scores[i] += 50

        similarity_liked = torch.tensor(
            [
                torch.dot(torch.tensor(post_embedding), torch.tensor(liked_embedding))
                for _, liked_embedding in liked_embeddings
            ]
        )
        similarity_disliked = torch.tensor(
            [
                torch.dot(
                    torch.tensor(post_embedding), torch.tensor(disliked_embedding)
                )
                for _, disliked_embedding in disliked_embeddings
            ]
        )

        recommendation_scores[i] += similarity_liked.mean() - similarity_disliked.mean()

    sorted_indices = torch.argsort(recommendation_scores, descending=True)
    recommended_post = [all_embeddings[i][0] for i in sorted_indices]

    return recommended_post
