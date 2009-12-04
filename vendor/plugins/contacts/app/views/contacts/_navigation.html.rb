panel t('contacts.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Actions" do  
        nav link_to("Add a new contact", new_contact_path)
        nav link_to("Check for potential duplicates")        
      end
      accordian_item "Import Contacts"  do
        nav link_to("from Microsoft Excel (.xls)")
        nav link_to("from vCards (.vcf)")
        nav link_to("from Comma Separated Values (.csv)")
        nav link_to("from LinkedIn")
      end
      accordian_item "Export Contacts" do
        nav link_to("to Comma Separted Values (.csv)")
        nav link_to("to XML (.xml)")       
      end
      accordian_item "Manage Contact Segments"  do
        nav link_to("Show segment index")
        nav link_to("Create new segment")      
      end
    end
  end
end