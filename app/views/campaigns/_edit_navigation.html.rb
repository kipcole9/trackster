panel t('campaigns.edit_navigation'), :class => 'accordian'  do
  block do
    if @campaign.preview_available? && current_user.is_administrator? && !@campaign.email_html.blank?
      p link_to t("campaigns.show_preview"), preview_campaign_path(@campaign)
    else
      p t('no_actions_available')
    end
  end
end