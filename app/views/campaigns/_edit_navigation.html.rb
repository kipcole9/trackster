panel t('panels.action_sidebar'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Actions" do
        nav link_to t("campaigns.show_preview"), preview_property_campaign_path(@property, @campaign)
        nav link_to t("properties.edit.edit_property", :name => @property.name), edit_property_path(@property)
      end          
    end    
  end
end
