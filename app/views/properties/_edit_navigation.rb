panel t('panels.property_edit_navigation')  do
  block do
    accordion do
      accordion_item "Actions" do
        nav link_to("Define a new property", new_property_path)
      end          
    end    
  end
end
