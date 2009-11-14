clear do
  column :width => 12 do
    with_tag(:div, :id => 'branding') do
      store image_tag("#{current_theme_path}/brand.png")
	  end
    with_tag(:div, :id => 'logo') do
      store image_tag("#{current_theme_path}/logo.png")
	  end
  end
end
