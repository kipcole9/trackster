panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/group.png'} Visitors" do  
        p link_to("Overview", property_report_path(@property, 'overview'))
        p link_to("Geography", property_report_path(@property, 'country'))
        p link_to("New vs Returning", property_report_path(@property, 'new_v_returning'))
        p link_to("Languages", property_report_path(@property, 'language'))
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Loyalty"  do
        p link_to("Overview")
        p link_to("Loyalty")
        p link_to("Recency")
        p link_to("Length of visit")
        p link_to("Depth of visit")        
      end
      accordian_item "#{image_tag '/images/icons/arrow_in.png'} Traffic Sources" do
        p link_to("Overview", property_report_path(@property, 'traffic_source'))
        p link_to("Direct traffic")
        p link_to("Referrals")
        p link_to("Search engines")
        p link_to("Keywords", property_report_path(@property, 'keywords'))
      end
      accordian_item "#{image_tag '/images/icons/magnifier.png'} Campaigns" do
        p link_to("Overview")
        p link_to("Impressions")
        p link_to("Clicks-through")
        p link_to("Link destinations")
      end      
      accordian_item "#{image_tag '/images/icons/newspaper.png'} Content" do 
        p link_to("Overview")
        p link_to("Top content")
        p link_to("Video content")
        p link_to("Content drill-down")
        p link_to("Top landing pages")
        p link_to("Top exit pages")
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
