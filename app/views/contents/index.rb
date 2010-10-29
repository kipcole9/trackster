panel t('panels.content_index') do  
  block do
    search t("search"), :id => "contentSearch", :replace => "content", :url => contents_url
    with_tag(:div, :id => 'content') do
      include 'index'
    end
  end
end
