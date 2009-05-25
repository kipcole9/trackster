panel t('panels.campaign'), :flash => true, :display_errors => 'redirect'  do
  block do
    store render :partial => 'campaign_form', :locals => {:campaign => @campaign ||= Campaign.new}
  end
end