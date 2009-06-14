panel t('contacts.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/group.png'} Actions" do  
        p link_to("Add a new contact")
        p link_to("View contact list")
        p link_to("Check for potential duplicates")        
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Import/Export Contacts"  do
        p link_to("Import contacts (xls, csv, vcard, salesforce.com)")
        p link_to("Export contacts (xls, csv, vcard, xml, json)")       
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Segments"  do
        p link_to("Show segment index")
        p link_to("Create new segment")      
      end
    end
  end
end