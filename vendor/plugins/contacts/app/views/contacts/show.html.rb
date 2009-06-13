panel @contact.full_name_and_title, :flash => true do
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

panel @contact.full_name_and_title + " recent history" do
  block do
    @histories = @contact.actions
    store render :file => 'histories/index'
  end
end