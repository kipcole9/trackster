panel t('navigation.reports')  do
  block do
    accordion do
      accordion_item "Visitors" do  
        nav report_link('overview')
        nav report_link('country')
        nav report_link('locality')        
        nav report_link('new_v_returning')
        nav report_link('language')
      end
      accordion_item "Loyalty"  do
        nav link_to("Overview")
        nav link_to("Loyalty")
        nav link_to("Recency")
        nav report_link('length_of_visit')
        nav report_link('depth_of_visit')        
      end
      accordion_item "Traffic Sources" do
        nav report_link('traffic_source')
        nav link_to("Direct traffic")
        nav link_to("Referrals")
        nav report_link('referrer_category')
        nav link_to("Search engines")
        nav report_link('keywords')
      end
      accordion_item "Campaigns" do
        nav report_link('campaign_overview')
        nav link_to("Impressions")
        nav link_to("Clicks-through")
        nav link_to("Link destinations")
      end      
      accordion_item "Content" do 
        nav link_to("Overview")
        nav report_link('url')
        nav report_link('page_title')
        nav report_link('entry_page')
        nav report_link('exit_page')
        nav report_link('bounce_page')
      end
      accordion_item "Events" do
        nav report_link('events')
        nav report_link('video')
        resource.video_labels.each do |video|
          unless video.blank?
            video_label = video.split('/').last
            nav video_report(video_label, :video => video) 
          end
        end; nil
      end
      accordion_item "Internal Search" do         
        nav link_to("Overview")
      end 
      accordion_item "Devices" do  
        nav link_to("Overview")
        nav report_link('device')
        nav report_link('browser')
        nav report_link('os_name')
        nav report_link('color_depth')
        nav report_link('screen_size')
        nav report_link('flash_version')
      end    
    end
  end
end
