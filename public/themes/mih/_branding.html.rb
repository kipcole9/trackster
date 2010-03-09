clear do
  column :width => 12, :id => 'custom-branding' do
    img "#{current_theme_path}/brand.png", :id => 'mih-branding'
    img "#{current_theme_path}/logo.png", :id => "logo"
  end
end
