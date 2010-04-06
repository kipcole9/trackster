panel t('contacts.navigation')  do
  block do
    accordion do
      accordion_item "Actions" do  
        nav link_to("Add a new contact", new_person_path)
        nav link_to("Import contacts", new_import_path)
        nav link_to("Undo last import")
      end
    end
  end
end