panel t('reports.name.video_summary', :name => params[:video] || t('videos.all')), :class => 'table'  do
  block do
    if @report.empty?
      h3 t('videos.no_video_plays_yet')
    else
      store @report.to_table
    end
  end
end