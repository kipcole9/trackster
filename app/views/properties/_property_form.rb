form_for property do |property|
  tab "property_form" do
    tab_item property.object.new_record? ? t('.new_property') : t('.edit_property', :name => property.object.name) do
      property.text_field     :name,              :validate => :validations
      property.text_area      :description
      property.text_field     :host,              :validate => :validations
    end
    tab_item t('.advanced') do
      property.text_field     :search_parameter,  :validate => :validations
      property.text_field     :index_page
      property.text_field     :title_prefix
    end
  end
  submit_combo
end