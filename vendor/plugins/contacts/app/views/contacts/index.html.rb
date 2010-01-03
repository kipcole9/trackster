panel t('panels.contacts_index') do
  block do
    search t(".name_search"), :id => :contactSearch, :search_id => :contactSearchField, 
      :replace => :contactCards, :url => contacts_url, :callback => "resizeContactCards();"
    store render 'contacts/index'
  end
end

keep :sidebar do
  store render 'contacts/navigation'
end