panel t('reports.name.video_maxplay', :name => params[:video] || t('videos.all'))  do
  block do
    video_maxplays = resource.video_play_time(params).all
    if video_maxplays.empty?
      h3 t('videos.no_video_plays_yet')
    else
      store video_maxplays.to_chart(:video_views, :max_play_time, :tooltip => "Max Play Time: #x_label#\nNumber of views: #val#")
    end
  end
end