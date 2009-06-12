clear do
  column :width => 12 do
    with_tag(:div, :id => 'branding') do
  	  # h1 link_to(Trackster::Config.banner, root_path)
  	  store "#{image_tag('/images/reel.png', :style => 'height:23px')}&nbsp;&nbsp;#{image_tag('/images/vieText.png', :style => 'height:23px')}"
  	  with_tag(:div) do
  	    store "#{I18n.t("logged_in_as", :name => current_user.name)} | #{link_to(I18n.t('logout'), logout_path)}" if logged_in?

	    end
	  end
  end
end
