caerus_form_for property do |property|
  fieldset property.object.new_record? ? t('.new_property') : t('.edit_property', :name => property.object.name) do
    property.text_field     :name,              :validate => :validations
    property.text_area      :description
    property.text_field     :host,              :validate => :validations
  end
  fieldset t('.advanced') do
    property.text_field     :search_parameter,  :validate => :validations
    property.text_field     :index_page
    property.text_field     :title_prefix
  end
  submit_combo
end