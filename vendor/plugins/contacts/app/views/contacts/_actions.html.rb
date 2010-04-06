panel t('panels.contact_actions', :name => @contact.full_name) do
  block do
    tab "contact_#{@contact['id']}" do
      tab_item "Add a Note" do
        store render :file => '/notes/new'
      end
      tab_item "Add a Task" do
        store "Tasks"
      end
      tab_item "Add an Important Date" do
        store "Dates"
      end
    end
  end
end