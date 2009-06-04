panel t('panels.redirect_index'), :flash => true do  
  block do
    search t("search"), :id => "redirectSearch", :replace => "redirect", :url => redirects_url
    with_tag(:div, :id => 'redirect') do
      render 'index'
    end
    store will_paginate
  end
end
