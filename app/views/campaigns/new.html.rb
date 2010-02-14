panel t('panels.campaign'), :flash => true, :display_errors => 'campaign'  do
  block do
    store render :partial => 'campaign_form', :locals => {:campaign => @campaign}
  end
end