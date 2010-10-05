module ContactsHelper
  def initialize_contact(contact)
    @contact = contact || current_account.contacts.build
    @contact.emails.build      if @contact.emails.empty?
    @contact.websites.build    if @contact.websites.empty?
    @contact.phones.build      if @contact.phones.empty?
    @contact.addresses.build   if @contact.addresses.empty?
    @contact
  end
  
  def phone_icon(phone)
    icon = image_tag("/images/icons/" + case phone.kind
      when 'cell'   then 'phone.png'
      when 'skype'  then 'skype.png'
      else 'telephone.png'
    end, :class => :icon)
  end
  
  def contacts
    @contacts = (@contacts  || @people || @organizations)
  end
  
end
