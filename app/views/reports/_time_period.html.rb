panel t('panels.time_dimension'), :class => 'accordion'  do
  block do
    accordion do
      accordion_item "Time Period" do  
        nav add_dimension(current_action, :period => 'today')
        nav add_dimension(current_action, :period => 'this_week')
        nav add_dimension(current_action, :period => 'this_month')        
        nav add_dimension(current_action, :period => 'last_30_days')
        nav add_dimension(current_action, :period => 'last_12_months')
        nav add_dimension(current_action, :period => 'lifetime')        
      end
      accordion_item "Time summarised by"  do
        nav add_dimension(current_action, :time_group => 'date')      
        nav add_dimension(current_action, :time_group => 'day_of_week')
        nav add_dimension(current_action, :time_group => 'hour_of_day')
        nav add_dimension(current_action, :time_group => 'day_of_month')
        nav add_dimension(current_action, :time_group => 'month_of_year')       
        nav add_dimension(current_action, :time_group => 'year')  
      end
    end
  end
end
