clear do
  column :width => 12, :id => 'custom-branding' do
    img "#{Trackster::Theme.current_theme_path}/brand.png", :id => 'mih-branding'
    img "#{Trackster::Theme.current_theme_path}/logo.png", :id => "logo"
  end
end
