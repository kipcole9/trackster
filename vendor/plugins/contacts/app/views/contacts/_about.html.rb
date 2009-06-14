panel I18n.t('contacts.name_card'), :edit => edit_contact_path(@contact) do
  block :id => 'about' do
    store render 'contacts/contact'
  end
end
