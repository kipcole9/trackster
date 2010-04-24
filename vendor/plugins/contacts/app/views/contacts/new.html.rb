# Create and edit a contact
panel t('panels.new_contact'), :display_errors => :person  do
  block do
    form_for initialize_contact(@person || @organization), :html => { :multipart => true }  do |contact|
      content_for :jstemplates, associated_template_for_new(contact, :emails)
      content_for :jstemplates, associated_template_for_new(contact, :websites)
      content_for :jstemplates, associated_template_for_new(contact, :phones)
      content_for :jstemplates, associated_template_for_new(contact, :addresses)
  
      fieldset I18n.t("contacts.#{contact.object.class.name.downcase}"), :id => :contact, :optional => :hide do
        render_form contact, (contact.object.is_a?(Organization) ? 'organization' : 'person')
      end
  
      fieldset I18n.t('contacts.phones'), :id => :phone, :buttons => :add do
        contact.fields_for :phones do |phone|
          render_form(phone, 'phone')
        end
      end

      fieldset I18n.t('contacts.email_addresses'), :id => :email, :buttons => :add do
        contact.fields_for :emails do |email|
          render_form email, 'email'
        end
      end

      fieldset I18n.t('contacts.websites'), :id => :website, :buttons => :add do
        contact.fields_for :websites do |website|
          render_form website, 'website'
        end
      end

      fieldset I18n.t('contacts.addresses'), :id => :address, :buttons => :add do
        contact.fields_for :addresses do |address|
          render_form address, 'address'
        end
      end
  
      submit_combo :text => 'save'
    end
  end
end


