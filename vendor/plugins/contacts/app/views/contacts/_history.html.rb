panel t("panels.contact_history", :name => @contact.full_name) do
  block do
    @histories = @contact.actions
    include 'histories/index'
  end
end
