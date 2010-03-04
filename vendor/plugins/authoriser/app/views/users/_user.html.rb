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
      h4 "#{user.name} #{content_tag(:span, I18n.t('users.states.passive'), :class => 'passive') if user.inactive?}"
      p user.email
    end
  end
end
  
