panel t('panels.contacts_index') do
  search t(".name_search"), :id => :contactSearch, :search_id => :contactSearchField, 
    :replace => :contactCards, :url => contacts_url, :callback => "$.updateContactCards();"
  include "contacts/index"
end


