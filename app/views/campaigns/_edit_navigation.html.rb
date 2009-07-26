panel t('campaigns.edit_navigation'), :class => 'accordian'  do
  block do
    p link_to t("campaigns.show_preview"), preview_campaign_path(@campaign)
  end
end