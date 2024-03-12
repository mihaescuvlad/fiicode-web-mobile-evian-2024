module CardsHelper
  def product_card(product)
    content_tag(:div, class: 'relative flex w-full z-0 flex-col rounded-xl bg-white bg-clip-border text-gray-700 shadow-lg max-w-[26rem]') do
      concat(content_tag(:div, class: 'relative mx-4 mt-4') do
        concat(content_tag(:div, class: 'flex flex-row items-center') do
          concat(content_tag(:i, '', class: 'mdi mdi-star text-yellow-400 mr-2', style: 'font-size: 1.5rem;'))
          concat(content_tag(:p, rating_text(product), class: 'font-sans text-base font-normal leading-relaxed text-primary-900 antialiased gap-1.5'))
        end)

        if current_user.present?
          concat(content_tag(:button, type: 'button', class: '!absolute top-0 right-0 h-8 w-8 select-none rounded-full text-center align-middle font-sans text-xs font-medium uppercase text-red-500 transition-all disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none max-h-[32px] max-w-[32px] hover:bg-red-500/10 active:bg-red-500/30') do
            concat(content_tag(:span, class: '-translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2') do
              concat(favorite_product_icon(product))
            end)
          end)
        end
        concat(content_tag(:hr, '', class: 'border-1 border-gray-400 rounded-lg mt-2'))
      end)

      concat(content_tag(:div, class: 'p-6') do
        concat(content_tag(:div, class: 'flex flex-col items-center justify-center mb-3') do
          concat(content_tag(:h5, product.name, class: 'block font-sans text-2xl antialiased font-medium leading-snug tracking-normal text-primary-900'))
          concat(content_tag(:h6, product.brand, class: 'block font-sans text-l antialiased font-medium leading-snug tracking-normal text-gray-400'))
        end)

        concat(content_tag(:div, class: 'flex items-center justify-center group gap-3 mt-4 pt-3') do
          concat(product_info_tag('mdi-fire', 'Calories', product.calories))
          concat(product_info_tag('mdi-water', 'Fat', product.fat))
          concat(product_info_tag('mdi-barley', 'Carbohydrates', product.carbohydrates))
          concat(product_info_tag('mdi-food-drumstick', 'Protein', product.protein))
        end)
      end)

      concat(content_tag(:div, class: 'p-6 pt-2') do
        concat(link_to('Read More', user_product_path(product), class: 'block w-full select-none rounded-lg bg-primary-500 px-7 text-center align-middle font-sans text-sm font-bold uppercase text-white shadow-md transition-all hover:shadow-lg focus:shadow-none active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none py-3.5 shadow-gray-900/10 hover:shadow-gray-900/20 focus:opacity-[0.85] active:opacity-[0.85]'))
      end)
    end
  end

  private

  def product_info_tag(icon_class, label, value)
    content_tag(:span, class: 'rounded-full border p-2 text-gray-900 border-gray-900/5 bg-gray-900/5') do
      concat(content_tag(:div, class: 'flex flex-row items-center') do
        concat(content_tag(:i, '', class: "mdi #{icon_class} mr-1", style: 'font-size: 1.5rem;'))
        concat(content_tag(:p, value, class: 'font-sans text-base font-normal leading-relaxed text-primary-900 antialiased gap-1.5'))
      end)
    end
  end

  def rating_text(product)
    reviews = Review.where(product_id: product.id)
    total_reviews = reviews.count
    if total_reviews > 0
      positive_review_percentage = (product.rating.to_f / total_reviews * 100)
      if positive_review_percentage.between?(45, 55)
        "Neutral"
      elsif positive_review_percentage.between?(56, 90)
        "Positive"
      elsif positive_review_percentage.between?(10, 44)
        "Negative"
      elsif positive_review_percentage > 90
        "Overwhelmingly Positive"
      else
        "Overwhelmingly Negative"
      end
    else
      "N/A"
    end
  end

  def favorite_product_icon(product)
    if current_user.favorites.include?(product.id)
      content_tag(:i, '', class: 'mdi mdi-heart', style: 'font-size: 1.5rem;', id: "heart-icon-#{product.id}")
    else
      content_tag(:i, '', class: 'mdi mdi-heart-outline', style: 'font-size: 1.5rem;', id: "heart-icon-#{product.id}")
    end
  end

end
