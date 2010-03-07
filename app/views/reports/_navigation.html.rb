panel t('navigation.reports')  do
  block do
    accordion do
      accordion_item "Visitors" do  
        nav report_link('visit_overview')
        nav report_link('country')
        nav report_link('locality')        
        nav report_link('new_v_returning')
        nav report_link('language')
      end
      accordion_item "Loyalty"  do
        nav report_link("loyalty_overview")
        nav report_link("loyalty")
        nav report_link("recency")
        nav report_link('length_of_visit')
        nav report_link('depth_of_visit')        
      end
      accordion_item "Traffic Sources" do
        nav report_link('traffic_source_overview')
        nav report_link("traffic_source")
        nav report_link('referrer_category')
        nav report_link("search_engines")
        nav report_link('keywords')
      end
      accordion_item "Campaigns" do
        nav report_link('campaign_overview')
        nav report_link("impressions")
        nav report_link("clicks_through")
        nav report_link("link_destinations")
      end      
      accordion_item "Content" do 
        nav report_link("content_overview")
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
        nav report_link("internal_search_overview")
      end 
      accordion_item "Devices" do  
        nav report_link("device_overview")
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
