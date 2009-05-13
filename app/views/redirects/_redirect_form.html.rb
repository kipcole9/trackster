caerus_form_for redirect do |redirect|
  fieldset redirect.object.new_record? ? t('.new_redirect') : t('.edit_redirect', :name => redirect.object.name) do
    redirect.text_field     :name, :validate => :validations
    redirect.select         :property_id, Property.find(:all).map{|p| [p.name, p.id]}    
    redirect.text_field     :url, :validate => :validations
    unless redirect.object.new_record?
      p "Redirection url is: #{link_to redirector_url(redirect.object.redirect_url),redirector_url(redirect.object.redirect_url) }"
    end
    redirect.text_field     :event_category
    redirect.text_field     :event_action
    redirect.text_field     :event_label
    redirect.text_field     :event_value
  end
  submit_combo
end