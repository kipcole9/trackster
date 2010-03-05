caerus_form_for property, :html => {:multipart => true} do |property|
  fieldset property.object.new_record? ? t('.new_property') : t('.edit_property', :name => property.object.name) do
    property.text_field     :name,              :validate => :validations
    property.text_field     :host,              :validate => :validations
    property.text_field     :search_parameter,  :validate => :validations
    property.text_field     :index_page
    property.text_area      :description
    store(image_tag(property.object.thumb(:thumb))) if property.object.thumb?
    property.file_field     :thumb
  end
  submit_combo
end