panel t('panels.time_dimension'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "#{image_tag '/images/icons/calendar.png'} Time Period" do  
        p add_dimension(current_action, :period => 'today')
        p add_dimension(current_action, :period => 'this_week')
        p add_dimension(current_action, :period => 'this_month')        
        p add_dimension(current_action, :period => 'last_30_days')
        p add_dimension(current_action, :period => 'last_12_months')
        p add_dimension(current_action, :period => 'lifetime')        
      end
      accordian_item "#{image_tag '/images/icons/clock.png'} Time summarised by"  do
        p add_dimension(current_action, :tgroup => 'date')      
        p add_dimension(current_action, :tgroup => 'day_of_week')
        p add_dimension(current_action, :tgroup => 'hour_of_day')
        p add_dimension(current_action, :tgroup => 'day_of_month')
        p add_dimension(current_action, :tgroup => 'month_of_year')       
      end
    end
  end
end
