panel t('.impressions_by_browser', :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table sixcol'  do
  block do
    @email_client_overview ||= resource.email_client_overview(params).all
    email_client_overview = @email_client_overview.reject{|item| item[:impressions] == 0 }
    if email_client_overview.empty?
      h3 t('no_impressions_yet')
    else
      total_impressions = email_client_overview.sum(:impressions)
      store email_client_overview.to_table(:percent_of_impressions => total_impressions)
    end
  end
end
