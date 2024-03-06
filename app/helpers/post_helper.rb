module PostHelper
  def show_post(post)
    if post.response_to.present?
      show_post(post.response_to).safe_concat(render(partial: "user/hub/posts/post", locals: { post: post }))
    else
      render partial: "user/hub/posts/post", locals: { post: post }
    end
  end
end