caerus_form_for campaign, :html => {:multipart => true} do |campaign|
  fieldset campaign.object.new_record? ? t('.new_campaign') : t('.edit_campaign', :name => campaign.object.name) do
    if current_user.has_role?(Role::ADMIN_ROLE)
      campaign.collection_select :account_id, Account.all, :id, :name
    end
    if @property || !campaign.object.new_record?
      campaign.hidden_field :property_id
    else
      campaign.collection_select :property_id, user_scope(:property, current_user).all, :id, :name
    end
    campaign.text_field     :name
    campaign.text_area      :description
    campaign.text_field     :cost,          :validate => :validations
  end
  fieldset t('.distribution') do
    campaign.text_field     :distribution,  :validate => :validations
    campaign.text_field     :bounces,       :validate => :validations
    campaign.text_field     :unsubscribes,  :validate => :validations
  end
  fieldset t('.coding') do
    campaign.text_field     :code, :disabled => 'disabled' unless campaign.object.new_record?
    campaign.file_field     :design_html
    campaign.file_field     :landing_html
  end
  submit_combo
end
