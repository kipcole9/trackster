caerus_form_for campaign do |campaign|
  fieldset campaign.object.new_record? ? t('.new_campaign') : t('.edit_campaign', :name => campaign.object.name) do
    campaign.hidden_field   :property_id
    campaign.hidden_field   :account_id
    campaign.text_field     :name
    campaign.text_area      :description
    campaign.text_field     :cost
  end
  fieldset t('.distribution') do
    campaign.text_field     :distribution
    campaign.text_field     :bounces
    campaign.text_field     :unsubscribes
  end
  fieldset t('.coding') do
    campaign.text_field     :code unless campaign.object.new_record?
    campaign.file_field     :design_html
    campaign.file_field     :landing_html
  end
  submit_combo
end
