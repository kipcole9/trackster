panel t('.page_views_top_10')  do
  block do
    store Track.page_views.by(:url).limit(10).order('count DESC').all.to_table
  end
end