if (campaigns = current_account.campaigns.active).empty?
  panel t("campaigns.reports.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
    block do
      h3 t('no_data_yet')
    end
  end
else
  campaigns.each do |campaign|
    panel t("campaigns.reports.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
      block do
        campaign_content = campaign.campaign_content(params).all
        if campaign_content.empty?
          h3 t('no_data_yet')
        else
          store campaign_content.to_table
        end
      end
    end
  end
end