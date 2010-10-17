panel t('.impressions_by_browser'), :class => 'table sixcol'  do
  block do
    impressions = resource.tracks.impressions.by(:email_client).order('impressions DESC').between(Period.from_params(params)).active(resource).all
    impressions.reject!{|item| item[:impressions] == 0 }
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      total_impressions = impressions.sum(:impressions)
      store impressions.to_table(:percent_of_impressions => total_impressions)
    end
  end
end
