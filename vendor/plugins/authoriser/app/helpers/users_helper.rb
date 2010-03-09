module UsersHelper
  def user_roles_check_boxes(user)
    store label_tag(I18n.t('activerecord.attributes.user.roles'))    
    User::ROLES.each do |r|
      with_tag(:div) do
        store check_box_tag("user[roles][]", r, user.has_role?(r))
        store content_tag(:label, I18n.t("roles.#{r}"), :class => :field_label)
      end
    end
    nil
  end
  
  def locales
    I18n.t('locales').sort{|a,b| a.first.to_s <=> b.first.to_s}
  end
  
  def user_states
    I18n.t('users.states').map {|state| [state.second.to_s, state.first.to_s]}
  end
end