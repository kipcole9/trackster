panel t('panels.campaign'), :display_errors => 'campaign'  do
  block do
    store render :partial => 'campaign_form', :locals => {:campaign => @campaign}
  end
end

keep :sidebar do
  column :width => 4, :class => "sidebar help" do
    include "campaign_help"
	end
end