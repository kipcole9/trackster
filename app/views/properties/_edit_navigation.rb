panel t('panels.property_edit_navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Actions" do
        nav link_to("Define a new property", new_property_path)
      end          
    end    
  end
end
