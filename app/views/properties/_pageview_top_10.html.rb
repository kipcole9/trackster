panel t('dashboards.page_views_top_10'), :class => 'table'  do
  block do
    page_views = @property.tracks.page_views.by(:url).limit(10).between(Track.period_from_params(params)).all
    if page_views.empty?
      h3 t('no_page_views_yet')
    else
      total_page_views = @property.tracks.page_views.between(Track.period_from_params(params)).first.page_views
      store page_views.to_table(:percent_of_page_views => total_page_views)
    end
  end
end