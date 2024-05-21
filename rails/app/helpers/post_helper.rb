module PostHelper
  def show_post(post, max_depth = 3, child = nil)
    children = if child.present? then
                 [child]
               else
                 post.responses.map { |p| render(partial: "user/hub/posts/post", locals: { post: p }) }
               end

    if post.response_to.present? and max_depth > 0
      show_post(post.response_to, max_depth - 1, render(partial: "user/hub/posts/post", locals: { post: post, children: children }))
    else
      render partial: "user/hub/posts/post", locals: { post: post, children: children }
    end
  end
end