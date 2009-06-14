# Create and edit a contact
panel t('contacts.edit_background', :name => @contact.full_name), :flash => true, :display_errors => :background  do
  block do
    caerus_form_for @background, :url => contact_background_path(@contact) do |background|
      fieldset I18n.t('contacts.background') do
        background.text_area :description
      end
      submit_combo :text => 'save'
    end
  end
end

keep :sidebar do
  store render 'contacts/about'
  store render 'background_formatting'
end