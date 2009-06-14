panel t('contacts.bio', :name => @contact.full_name), :edit => edit_contact_background_path(@contact)  do
  block :id => 'bio' do
    if @contact.background
      store (@contact.background.description.textilize)
    else
      p t('backgrounds.no_bio_available')
    end
  end
end