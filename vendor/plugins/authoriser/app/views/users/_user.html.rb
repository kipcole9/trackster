with_tag(:div, :id => "user_#{user['id']}") do
  clear do
    float :left do
      if user && user.photo?
        img user.photo(:avatar), :class => :list_image
      else
        img '/images/list_icons/users.gif', :class => :list_image
      end
    end
    float :left do
      h4 user.name
      p user.email
    end
  end
end
  
