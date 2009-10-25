panel t('dashboards.video_summary', :name => params[:video] || t('videos.all')), :class => 'table'  do
  if @videos.empty?
    block do
      h3 t('videos.no_video_plays_yet')
    end
  else
    video_reports = 0
    @videos.each do |video|
      @events_summary = @property.video_summary(video, params).all
      unless @events_summary.empty?
        block do
          h3 I18n.t('videos.video', :name => video) unless @videos.size == 1
          store @events_summary.to_table
          video_reports += 1
        end
      end
    end
    block {h3 t('videos.no_video_plays_yet') if video_reports = 0}
  end
end