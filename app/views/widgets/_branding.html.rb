column :width => 12 do
  with_tag(:div, :id => 'branding') do
    if current_account && current_account.logo?
      store image_tag(current_account.logo(:banner))
    else
	    h1 link_to(Trackster::Config.banner, root_path)
    end
	  with_tag(:div) do
	    store I18n.t("logged_in_as", :name => link_to(current_user.name, edit_user_path(current_user), :title => t('users.edit_profile')))
	    store " | #{link_to(I18n.t('change_password'), change_password_path)}"
	    store " | #{link_to(I18n.t('logout'), logout_path)}"
    end if logged_in?
  end
end

