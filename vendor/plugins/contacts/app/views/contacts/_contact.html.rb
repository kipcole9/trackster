# Render and object in business card layout
with_tag(:div, :class => "contactCard", :id => "contact_#{contact['id']}") do
  img contact.photo.url(:avatar), :class => :avatar if contact.photo?
  h3 link_to(contact.full_name, contact_url(contact))
  h4 contact.role unless contact.role.blank?
  h4 contact.organization_name unless contact.organization_name.blank? || contact.is_a?(Organization)
  contact.phones.each   {|phone| p "#{phone_icon(phone)} #{phone.number}", :class => :phone}
  contact.emails.each   {|e| p "#{image_tag '/images/icons/email.png', 
                        :class => :icon} #{link_to e.address, 'mailto:' + e.address}", :class => :email }
  contact.websites.each {|w| p "#{image_tag '/images/icons/world.png', 
                        :class => :icon} #{link_to w.url, w.url}", :class => :website }
  img '/images/icons/arrow_join.png', :class => :merge, :title => tt('merge_into_another_contact')
end