panel t('reports.name.video_summary', :name => params[:video] || t('videos.all')), :class => 'table'  do
  block do
    if @report.empty?
      h3 t('videos.no_video_plays_yet')
    else
      total_views = @report.make_numeric(:video_views).sum(:video_views)
      store @report.to_table(:percent_of_video_views => total_views)
    end
  end
end