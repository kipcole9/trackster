clear do
  column :width => 12, :id => 'custom-branding' do
    with_tag :div do
      img "#{Trackster::Theme.current_theme_path}/brand.png", :id => 'mih-branding'
    end
    h1 page_title
    with_tag :div do
      img "#{Trackster::Theme.current_theme_path}/logo.png", :id => "logo"
    end
  end
end
