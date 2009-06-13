# Create and edit a contact
panel t('panels.edit_contact', :name => @contact.full_name), :flash => true, :display_errors => :contact  do
  block do
    caerus_form_for initialize_contact(@contact), :url => contact_path(@contact), :html => { :multipart => true }  do |contact|
      content_for :jstemplates, associated_template_for_new(contact, :emails)
      content_for :jstemplates, associated_template_for_new(contact, :websites)
      content_for :jstemplates, associated_template_for_new(contact, :phones)
      content_for :jstemplates, associated_template_for_new(contact, :addresses)
      
      fieldset contact.object.class.name, :id => :contact, :optional => :show do
        render_form contact, (contact.object.is_a?(Person) ? 'person' : 'organization')
      end
      
      fieldset Phone.human_name, :id => :phone, :buttons => :add do
        contact.fields_for :phones do |phone|
          render_form phone, 'phone'
        end
      end

      fieldset Email.human_name, :id => :email, :buttons => :add do
        contact.fields_for :emails do |email|
          render_form email, 'email'
        end
      end

      fieldset Website.human_name, :id => :website, :buttons => :add do
        contact.fields_for :websites do |website|
          render_form website, 'website'
        end
      end
    
      fieldset Address.human_name, :id => :address, :buttons => :add do
        contact.fields_for :addresses do |address|
          render_form address, 'address'
        end
      end
      
      submit_combo :text => 'save'
    end
  end
end
