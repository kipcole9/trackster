panel t('panels.campaign'), :display_errors => 'campaign'  do
  block do
    store render :partial => 'campaign_form', :locals => {:campaign => @campaign}
  end
end

keep :sidebar do
  column :width => 4 do
    panel t('panels.campaign_navigation') do
      block do
        accordion :id => 'campaign_navigation' do
          accordion_item "Campaign" do
            nav link_to("Preview", preview_campaign_path(resource))
          end          
        end   
      end
    end
  end  
end if params[:action] == 'edit'