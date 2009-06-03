panel t('panels.navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/money_dollar.png'} Campaigns" do
        p link_to("Overview")
        p link_to("Impressions")
        p link_to("Clicks-through")
        p link_to("Link destinations")
      end          
    end
  end
end
