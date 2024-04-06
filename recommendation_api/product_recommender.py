from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler

def compute_similarity(product1, product2, user_allergens=[], user_dietary_preferences=[]):
    scaler = MinMaxScaler()
    attributes1 = scaler.fit_transform(
        [[product1.calories, product1.fat, product1.carbohydrates, product1.protein]]
    )
    attributes2 = scaler.transform(
        [[product2.calories, product2.fat, product2.carbohydrates, product2.protein]]
    )

    numeric_similarity = cosine_similarity(attributes1, attributes2)[0][0]

    # Jaccard
    ingredients_set1 = set(product1.ingredients)
    ingredients_set2 = set(product2.ingredients)

    if len(ingredients_set1) == 0 and len(ingredients_set2) == 0:
        ingredients_similarity = 1.0
    elif len(ingredients_set1) == 0 or len(ingredients_set2) == 0:
        ingredients_similarity = 0.0
    else:
        ingredients_similarity = len(
            ingredients_set1.intersection(ingredients_set2)
        ) / len(ingredients_set1.union(ingredients_set2))

    allergen_penalty = 0.0
    if any(allergen in product2.allergens for allergen in user_allergens):
        allergen_penalty = 0.035

    dietary_penalty = 0.0
    if "VEGAN" in user_dietary_preferences and not product2.vegan:
        dietary_penalty += 0.01
    if "VEGETARIAN" in user_dietary_preferences and not product2.vegetarian:
        dietary_penalty += 0.01

    similarity_score = 0.7 * numeric_similarity + 0.3 * ingredients_similarity - allergen_penalty - dietary_penalty
    return similarity_score


def recommend_products(user_basket, all_products, user_allergens=[], user_dietary_preferences=[], N=9):
    if not user_basket:
        return sorted(all_products, key=lambda x: x.rating, reverse=True)

    available_products = [
        product for product in all_products if product not in user_basket
    ]
    recommendations = []

    for available_product in available_products:
        similarity_scores = [compute_similarity(user_product, available_product, user_allergens, user_dietary_preferences) for user_product in user_basket]
        average_similarity = sum(similarity_scores) / len(similarity_scores)

        recommendations.append((available_product, average_similarity))

    recommendations.sort(key=lambda x: x[1], reverse=True)
    recommended_products = [product for product, _ in recommendations]
    return recommended_products[:N]
