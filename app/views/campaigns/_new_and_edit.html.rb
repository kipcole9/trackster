panel t('panels.campaign'), :display_errors => 'campaign'  do
  block do
    store render :partial => 'campaign_form', :locals => {:campaign => @campaign}
  end
end