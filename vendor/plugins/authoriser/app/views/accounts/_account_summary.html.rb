clear do 
  float :left do
    img '/images/list_icons/account.png', :class => :list_image
  end
  float :left do
    h4 link_to("#{account.name}", account_url(account.id))
    p account.description, :style => (account.description.blank? ? "display:none" : "")
  end

  with_tag(:div, :class => :buttons, :style => "display:none") do
    store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), account_url(account), 
                          :method => :delete, :confirm => t('.delete_account', :property => account.name))
    store link_to(image_tag('/images/icons/add.png', :class => :addListItem), new_account_url)
    store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), edit_account_path(account))
  end
end



