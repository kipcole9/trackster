panel t('contacts.about', :name => @contact.full_name)  do
  block :id => 'bio' do
    store (@contact.background.description.textilize) if @contact.background
  end
end