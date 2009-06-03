panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/group.png'} Visitors" do  
        p link_to("Overview", property_report_path(@property, 'overview'))
        p link_to("Country", property_report_path(@property, 'country'))
        p link_to("Locality", property_report_path(@property, 'locality'))        
        p link_to("New vs Returning", property_report_path(@property, 'new_v_returning'))
        p link_to("Languages", property_report_path(@property, 'language'))
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Loyalty"  do
        p link_to("Overview")
        p link_to("Loyalty")
        p link_to("Recency")
        p link_to("Length of visit", property_report_path(@property, 'length_of_visit'))
        p link_to("Depth of visit", property_report_path(@property, 'depth_of_visit'))        
      end
      accordian_item "#{image_tag '/images/icons/arrow_in.png'} Traffic Sources" do
        p link_to("Overview", property_report_path(@property, 'traffic_source'))
        p link_to("Direct traffic")
        p link_to("Referrals")
        p link_to("Search engines")
        p link_to("Keywords", property_report_path(@property, 'keywords'))
      end
      accordian_item "#{image_tag '/images/icons/money_dollar.png'} Campaigns", :open => true do
        p link_to("Overview", property_report_path(@property, 'campaign_overview'))
        p link_to("Impressions")
        p link_to("Clicks-through")
        p link_to("Link destinations")
      end      
      accordian_item "#{image_tag '/images/icons/newspaper.png'} Content" do 
        p link_to("Overview")
        p link_to("Content by URL", property_report_path(@property, 'url'))
        p link_to("Content by page title", property_report_path(@property, 'page_title'))
        p link_to("Top entry pages", property_report_path(@property, 'entry_page'))
        p link_to("Top exit pages", property_report_path(@property, 'entry_page'))
        p link_to("Top bounce pages", property_report_path(@property, 'bounce_page'))
      end
      accordian_item "#{image_tag '/images/icons/lightning.png'} Events" do
        p link_to("Video content")
        p link_to("Content drill-down")
      end
      accordian_item "#{image_tag '/images/icons/magnifier.png'} Internal Search" do         
        p link_to("Internal search")
      end 
      accordian_item "#{image_tag '/images/icons/phone.png'} Platforms & Devices" do  
        p link_to("Overview")
        p link_to("Mobile devices", property_report_path(@property, 'device'))
        p link_to("Browsers", property_report_path(@property, 'browser'))
        p link_to("Operating systems", property_report_path(@property, 'os_name'))
        p link_to("Screen colors", property_report_path(@property, 'color_depth'))
        p link_to("Screen resolutions", property_report_path(@property, 'screen_size'))
        p link_to("Flash versions", property_report_path(@property, 'flash_version'))
      end    
    end
  end
end
