panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Visitors" do  
        nav property_report('overview')
        nav property_report('country')
        nav property_report('locality')        
        nav property_report('new_v_returning')
        nav property_report('language')
      end
      accordian_item "Loyalty"  do
        nav link_to("Overview")
        nav link_to("Loyalty")
        nav link_to("Recency")
        nav property_report('length_of_visit')
        nav property_report('depth_of_visit')        
      end
      accordian_item "Traffic Sources" do
        nav property_report('traffic_source')
        nav link_to("Direct traffic")
        nav link_to("Referrals")
        nav link_to("Search engines")
        nav property_report('keywords')
      end
      accordian_item "Campaigns" do
        nav property_report('campaign_overview')
        nav link_to("Impressions")
        nav link_to("Clicks-through")
        nav link_to("Link destinations")
      end      
      accordian_item "Content" do 
        nav link_to("Overview")
        nav property_report('url')
        nav property_report('page_title')
        nav property_report('entry_page')
        nav property_report('exit_page')
        nav property_report('bounce_page')
      end
      accordian_item "Events" do
        nav property_report('events')
        nav property_report('video')
        resource.video_labels.each do |video|
          unless video.blank?
            video_label = video.split('/').last
            nav video_report(video_label, :video => video) 
          end
        end; nil
      end
      accordian_item "Internal Search" do         
        nav link_to("Overview")
      end 
      accordian_item "Devices" do  
        nav link_to("Overview")
        nav property_report('device')
        nav property_report('browser')
        nav property_report('os_name')
        nav property_report('color_depth')
        nav property_report('screen_size')
        nav property_report('flash_version')
      end    
    end
  end
end
