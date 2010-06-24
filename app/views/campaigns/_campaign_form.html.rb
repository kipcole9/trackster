form_for campaign, :html => {:multipart => true} do |campaign|
  tab "campaign" do
    tab_item campaign.object.new_record? ? t('.new_campaign') : t('.edit_campaign', :name => campaign.object.name) do
      campaign.text_field     :name
      campaign.datetime_select  :effective_at
      campaign.text_area      :description
      campaign.text_field     :cost,          :validate => :validations
      campaign.text_field     :code, :disabled => 'disabled' unless campaign.object.new_record?
    end
    tab_item t('.distribution') do
      campaign.text_field     :distribution,  :validate => :validations
      campaign.text_field     :bounces,       :validate => :validations
      campaign.text_field     :unsubscribes,  :validate => :validations
    end
    tab_item t('.parameters') do
      campaign.text_field     :source
      campaign.text_field     :content
      campaign.text_field     :medium, :disabled => true
      campaign.text_field     :contact_code
    end
    tab_item t('.list') do
      p "This is where we'll select the list to send the campaign to"
    end
    tab_item t('.html') do
      campaign.select         :email, current_account.contents.all.map{|c| [c.name, c.id]}
      campaign.text_field     :image_directory
      campaign.check_box      :preview_available if current_user.is_administrator?    
    end
  end
  submit_combo
end
