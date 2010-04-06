panel t('panels.contact_events', :name => @contact.full_name) do
  block do
    if (tracks = @contact.tracks).empty?
      h3 I18n.t('contacts.no_events_detected')
    else
      with_tag :ul do
        tracks.each do |track|
          with_tag :li do
            p "Visited #{time_ago_in_words track.started_at} ago and viewed #{track.page_views} pages over #{track.duration}."
          end
        end
      end
    end
  end
end