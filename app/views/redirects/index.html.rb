panel t('panels.redirect_index'), :flash => true do  
  block do
    search t("search"), :id => "redirectSearch", :replace => "redirect", :url => property_redirects_path(@property)
    with_tag(:div, :id => 'redirect') do
      store render 'index'
    end
  end
end
