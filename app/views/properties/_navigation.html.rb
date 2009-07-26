panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/group.png'} Visitors" do  
        p property_report('overview')
        p property_report('country')
        p property_report('locality')        
        p property_report('new_v_returning')
        p property_report('language')
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Loyalty"  do
        p link_to("Overview")
        p link_to("Loyalty")
        p link_to("Recency")
        p property_report('length_of_visit')
        p property_report('depth_of_visit')        
      end
      accordian_item "#{image_tag '/images/icons/arrow_in.png'} Traffic Sources" do
        p property_report('traffic_source')
        p link_to("Direct traffic")
        p link_to("Referrals")
        p link_to("Search engines")
        p property_report('keywords')
      end
      accordian_item "#{image_tag '/images/icons/money_dollar.png'} Campaigns" do
        p property_report('campaign_overview')
        p link_to("Impressions")
        p link_to("Clicks-through")
        p link_to("Link destinations")
      end      
      accordian_item "#{image_tag '/images/icons/newspaper.png'} Content" do 
        p link_to("Overview")
        p property_report('url')
        p property_report('page_title')
        p property_report('entry_page')
        p property_report('entry_page')
        p property_report('bounce_page')
      end
      accordian_item "#{image_tag '/images/icons/lightning.png'} Events" do
        p property_report('events')
        p property_report('video')
        @property.video_labels.each do |video|
          unless video.blank?
            video_label = video.split('/').last
            p property_report('video', :video => video) 
          end
        end; nil
      end
      accordian_item "#{image_tag '/images/icons/magnifier.png'} Internal Search" do         
        p link_to("Overview")
      end 
      accordian_item "#{image_tag '/images/icons/phone.png'} Platforms & Devices" do  
        p link_to("Overview")
        p property_report('device')
        p property_report('browser')
        p property_report('os_name')
        p property_report('color_depth')
        p property_report('screen_size')
        p property_report('flash_version')
      end    
    end
  end
end
