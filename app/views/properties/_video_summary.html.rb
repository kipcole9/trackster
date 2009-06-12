panel t('dashboards.video_summary', :name => params[:video] || t('videos.all')), :class => 'table'  do
  if @videos.empty?
    block do
      h3 t('videos.no_video_plays_yet')
    end
  else
    @videos.each do |video|
      block do
        @events_summary = @property.video_summary(video, params).all
        unless @events_summary.empty?
          h3 I18n.t('videos.video', :name => video) unless @videos.size == 1
          store @events_summary.to_table
        end
      end
    end
  end
end