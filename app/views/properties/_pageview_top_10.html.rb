panel t('dashboards.page_views_top_10'), :class => 'table'  do
  block do
    total_page_views = @property.tracks.page_views(:with_events).between(Track.period_from_params(params)).first.page_views
    page_views = @property.tracks.page_views(:with_events).by(:url).order('page_views DESC').limit(10).between(Track.period_from_params(params)).all
    if page_views.empty?
      h3 t('no_page_views_yet')
    else
      store page_views.to_table(:percent_of_page_views => total_page_views)
    end
  end
end