form_for campaign, :html => {:multipart => true} do |campaign|
  tab "campaign" do
    tab_item campaign.object.new_record? ? t('.new_campaign') : t('.edit_campaign', :name => campaign.object.name) do
      campaign.text_field     :name
      campaign.datetime_select :effective_at
      campaign.datetime_select :concludes_at, :default => default_concludes_at
      campaign.text_area      :description
      if current_account.contents.empty?
        flash.now[:alert] = t('.no_content_defined', :link => new_content_path)
        nil
      else
        campaign.select       :email, current_account.contents.selection
      end
      # campaign.text_field     :code, :disabled => 'disabled' unless campaign.object.new_record?
    end
    tab_item t('.distribution') do
      campaign.text_field     :cost,          :validate => :validations
      campaign.text_field     :distribution,  :validate => :validations
      campaign.text_field     :bounces,       :validate => :validations
      campaign.text_field     :unsubscribes,  :validate => :validations
    end
    tab_item t('.parameters') do
      campaign.text_field     :source
      # campaign.text_field     :content
      # campaign.text_field     :medium, :disabled => true
      campaign.text_field     :contact_code
    end
    tab_item t('.list') do
      p "This is where we'll select the list to send the campaign to"
    end
  end
  submit_combo
end
