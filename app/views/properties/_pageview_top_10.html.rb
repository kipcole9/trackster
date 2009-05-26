panel t('dashboards.page_views_top_10'), :class => 'table'  do
  block do
    page_views = @property.tracks.page_views(:with_events).by(:url).limit(10).order('page_views DESC').all
    if page_views.empty?
      store t('.no_page_views_yet')
    else
      store page_views.to_table
    end
  end
end