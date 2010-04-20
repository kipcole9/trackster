cache "reports/navigation/time-dimensions/#{I18n.locale}" do
  panel t('navigation.time_dimension')  do
    block do
      accordion do
        accordion_item "Time Period" do  
          nav add_dimension(current_action, :period => 'today')
          nav add_dimension(current_action, :period => 'yesterday')
          nav add_dimension(current_action, :period => 'this_week')
          nav add_dimension(current_action, :period => 'this_month')       
          nav add_dimension(current_action, :period => 'this_year')  
          nav add_dimension(current_action, :period => 'last_week')  
          nav add_dimension(current_action, :period => 'last_month')  
          nav add_dimension(current_action, :period => 'last_year')        
          nav add_dimension(current_action, :period => 'last_30_days')
          nav add_dimension(current_action, :period => 'last_12_months')
          nav add_dimension(current_action, :period => 'lifetime')        
        end
        accordion_item "Time summarised by"  do
          nav add_dimension(current_action, :time_group => 'date')      
          nav add_dimension(current_action, :time_group => 'day_of_week')
          nav add_dimension(current_action, :time_group => 'hour')
          nav add_dimension(current_action, :time_group => 'day')
          nav add_dimension(current_action, :time_group => 'month')       
          nav add_dimension(current_action, :time_group => 'year')  
        end
      end
    end
  end
end