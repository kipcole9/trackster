cache :key => ['branding', current_account.name] do
  column :width => 12 do
    with_tag(:div, :id => 'branding') do
      if current_account && current_account.logo?
        store image_tag(current_account.logo(:banner))
      else
  	    h1 link_to(Trackster::Config.banner, root_path)
      end
    end
  end
end

