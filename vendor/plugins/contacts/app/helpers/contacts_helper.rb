module ContactsHelper
  def initialize_contact(contact)
    @contact = current_account.contacts.build unless contact
    returning(@contact) do |c|
      c.emails.build if c.emails.empty?
      c.websites.build if c.websites.empty?
      c.phones.build if c.phones.empty?
      c.addresses.build if c.addresses.empty?
    end
  end
  
  def phone_icon(phone)
    icon = image_tag("/images/icons/" + case phone.kind
      when 'cell'   then 'phone.png'
      when 'skype'  then 'skype.png'
      else 'telephone.png'
    end, :class => :icon)
  end
  
end
