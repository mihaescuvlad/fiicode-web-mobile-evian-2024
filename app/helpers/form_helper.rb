module FormHelper
  def controlled_form(url_for_options = {}, options = {}, &block)
    form_tag(url_for_options, options, &block).safe_concat(
      "<script>new FormController('#{options[:id]}');</script>".html_safe
    )
  end
end