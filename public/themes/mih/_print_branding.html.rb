clear do
  column :width => 12, :id => 'custom-branding' do
    with_tag(:table) do
      with_tag :tr do
        with_tag :td, :id => 'brand-logo' do
          img "#{Trackster::Theme.current_theme_path}/brand_print.png", :id => 'mih-branding'
        end
        with_tag :td, :id => 'report-heading' do
          h1 page_title
        end
        with_tag :td, :id => 'company-logo' do
          img "#{Trackster::Theme.current_theme_path}/logo_print.gif", :id => "logo"
        end
      end
    end
  end
end
