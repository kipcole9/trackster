panel t('panels.action_sidebar'), :class => 'accordian'  do
  block do
    accordion do
      accordion_item "Actions" do
        nav link_to t("campaigns.show_preview"), campaign_path(@campaign) if @campaign && !@campaign.new_record?
      end          
    end    
  end
end
