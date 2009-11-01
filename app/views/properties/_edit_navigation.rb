panel t('panels.property_edit_navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/lightning.png'} Actions" do
        p link_to("Show Property Redirects", property_redirects_path(@property))
      end          
    end    
  end
end
