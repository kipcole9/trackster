panel t('panels.redirect_index'), :flash => true do  
  block do
    search t("search"), :id => "redirectSearch", :replace => "redirect", :url => redirects_url
    render_list @redirects, :partial => 'redirect_summary', :buttons => :all
    store will_paginate
  end
end
