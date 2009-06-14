panel I18n.t('contacts.name_card', :name => @contact.full_name) do
  block :id => 'about' do
    store render 'contacts/contact'
  end
end
