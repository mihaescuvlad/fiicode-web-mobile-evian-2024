module FormHelper
  def controlled_form(url_for_options = {}, options = {}, &block)
    if options[:id].blank?
      options[:id] = "form-#{SecureRandom.uuid}"
    end

    form_tag(url_for_options, options, &block).safe_concat(
      "<script>$(document).ready(() => {document.getElementById('#{options[:id]}').method = '#{options[:method]}'; new FormController('#{options[:id]}')});</script>".html_safe
    )
  end
end