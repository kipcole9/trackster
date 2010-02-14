column :width => 9 do
  panel t('panels.contacts_index') do
    search t(".name_search"), :id => :contactSearch, :search_id => :contactSearchField, 
      :replace => :contactCards, :url => contacts_url, :callback => "$.resizeContactCards();"
    include "contacts/index"
  end
end

column  :width => 3 do
  include 'contacts/navigation'
end

