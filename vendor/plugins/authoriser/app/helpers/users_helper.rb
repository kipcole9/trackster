module UsersHelper
  def user_roles_check_boxes(user)
    User::ROLES.each do |r|
      with_tag(:div) do
        store check_box_tag("roles[]", r, user.has_role?(r))
        store content_tag(:label, I18n.t("roles.#{r}"), :class => :field_label)
      end
    end
    nil
  end
  
  def locales
    I18n.t('locales').sort{|a,b| a.first.to_s <=> b.first.to_s}
  end
  
  def user_states
    I18n.t('users.states').map {|state| [state.second, state.first]}
  end
end