panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/group.png'} Visitors" do  
        p link_to("Overview")
        p link_to("Geography", property_report_path(@property, 'geography'))
        p link_to("New vs Returning")
        p link_to("Languages")
      end
      accordian_item "#{image_tag '/images/icons/heart.png'} Loyalty"  do
        p link_to("Overview")
        p link_to("Loyalty")
        p link_to("Recency")
        p link_to("Length of visit")
        p link_to("Depth of visit")        
      end
      accordian_item "#{image_tag '/images/icons/arrow_in.png'} Traffic Sources" do
        p link_to("Overview")
        p link_to("Direct traffic")
        p link_to("Referrals")
        p link_to("Search engines")
        p link_to("Keywords")
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
        p link_to("Mobile devices")
        p link_to("Browsers")
        p link_to("Operating systems")
        p link_to("Screen colors")
        p link_to("Screen resolutions")
        p link_to("Flash versions")
      end    
    end
  end
end
