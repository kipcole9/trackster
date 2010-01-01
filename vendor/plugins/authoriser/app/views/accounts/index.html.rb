panel t('panels.account_index'), :flash => true do  
  block do
    search t("search"), :id => "accountSearch", :replace => "account", :url => accounts_url
    with_tag(:div, :id => 'account') do
      store render :partial => 'index'
    end
    store will_paginate
  end
end
