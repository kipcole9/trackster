# Create and edit a contact
@background = @contact.build_background unless @background
panel t('contacts.edit_background', :name => @contact.full_name), :flash => true, :display_errors => :background  do
  block do
    form_for @background, :url => contact_background_path(@contact) do |background|
      fieldset I18n.t('contacts.background') do
        background.text_area :description, :size => "50x8"
      end
      submit_combo :text => 'save'
    end
  end
end
