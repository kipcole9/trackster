panel t('panels.time_dimension'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/calendar.png'} Time Period" do  
        p link_to("Today", property_report_path(@property, params[:action], report_params.merge(:period => 'today')))
        p link_to("This week", property_report_path(@property, params[:action], report_params.merge(:period => 'this_week')))
        p link_to("This month", property_report_path(@property, params[:action], report_params.merge(:period => 'this_month')))        
        p link_to("Last 30 days", property_report_path(@property, params[:action], report_params.merge(:period => 'last_30_days')))
        p link_to("Last 12 months", property_report_path(@property, params[:action], report_params.merge(:period => 'last_12_months')))
        p link_to("Lifetime of site", property_report_path(@property, params[:action], report_params.merge(:period => 'lifetime')))        
      end
      accordian_item "#{image_tag '/images/icons/clock.png'} Time summarised by"  do
        p link_to("Date", property_report_path(@property, params[:action], report_params.merge(:tgroup => 'date')))        
        p link_to("Day of Week", property_report_path(@property, params[:action], report_params.merge(:tgroup => 'day_of_week')))
        p link_to("Hour of Day", property_report_path(@property, params[:action], report_params.merge(:tgroup => 'hour_of_day')))
        p link_to("Day of Month", property_report_path(@property, params[:action], report_params.merge(:tgroup => 'day_of_month')))
        p link_to("Month of Year", property_report_path(@property, params[:action], report_params.merge(:period => 'month_of_year')))       
      end
    end
  end
end
