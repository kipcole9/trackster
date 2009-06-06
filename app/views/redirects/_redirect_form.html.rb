url = redirect.new_record? ? property_redirects_path(@property) : property_redirect_path(@property)
caerus_form_for redirect, :url => url do |redirect|
  fieldset redirect.object.new_record? ? t('.new_redirect') : t('.edit_redirect', :name => redirect.object.name) do
    redirect.text_field     :name, :validate => :validations   
    redirect.text_field     :url, :validate => :validations
    unless redirect.object.new_record?
      p "Redirection url is: #{link_to redirector_url(redirect.object.redirect_url),redirector_url(redirect.object.redirect_url) }"
    end
    redirect.text_field     :category
    redirect.text_field     :action
    redirect.text_field     :label
    redirect.text_field     :value
  end
  submit_combo
end