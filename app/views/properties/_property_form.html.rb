caerus_form_for property do |property|
  fieldset property.object.new_record? ? t('.new_property') : t('.edit_property', :name => property.object.name) do
    property.text_field     :name,              :validate => :validations
    property.text_field     :url,               :validate => :validations
    property.text_field     :search_parameter,  :validate => :validations
    property.text_area      :description
    unless property.object.new_record?
      property.text_field   :tracker, :disabled => 'disabled' 
    end
  end
  submit_combo
end