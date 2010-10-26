module Analytics
  module Model
    module ColumnFormats
      def self.included(base)
        base.class_eval do
          column_format :count,          :total => :sum, :order => 99
          column_format :event_count,    :order => 20

          column_format :distribution,   :order => 10, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
          column_format :bounces,        :order => 15, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
          column_format :unsubscribes,   :order => 20, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
          column_format :deliveries,     :order => 25, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
          column_format :impressions,    :order => 30, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter 
          column_format :clicks_through, :order => 35, :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
          column_format :click_through_rate, :total => :avg, :order => 36, :formatter => :bar_and_percentage
          column_format :open_rate,       :total => :sum, :order => 32, :class => 'page_views', :formatter => :bar_and_percentage 

          column_format :page_views,     :total => :sum, :order => 99, :class => 'page_views right'
          column_format :visits,         :total => :sum, :order => 50, :class => 'right', :formatter => :integer_with_delimiter
          column_format :page_views,     :total => :sum, :order => 50, :class => 'right', :formatter => :integer_with_delimiter
          column_format :duration,       :total => :avg, :order => 98, :class => 'right', :formatter => :seconds_to_time
          column_format :hour,           :total => :avg, :order => 90, :class => 'right', :formatter => :hours_to_time
          column_format :day_of_month,   :order => 90, :class => 'right', :formatter => :ordinalize
          column_format :date,           :formatter => :short_date
          column_format :month,          :formatter => :long_month_name
          column_format :day_of_week,    :formatter => :long_day_name
          column_format :first_impression, :order => 5
          column_format :contact_code,    :order => 1, :formatter => :unknown_on_blank
          
          column_format :max_play_time,   :order => 7, :class => 'center', :formatter => :seconds_to_time
          column_format :video_views,     :order => 8,  :class => 'right', :formatter => :integer_with_delimiter
          column_format :percent_of_video_views, :order => 9, :formatter => :bar_and_percentage
          
          column_format :campaign_name,  :order => -1
          column_format :cost,           :total => :sum, :order => 30, :class => 'right', :formatter => :integer_with_delimiter 
          column_format :cost_per_impression,  :total => :avg, :order => 40, :class => 'right', :formatter => :currency_without_sign

          column_format :percent_of_clicks_through,  :total => :sum, :order => 96, :class => 'clicks_through', :formatter => :bar_and_percentage 

          column_format :cost_per_click, :total => :avg, :order => 50, :class => 'right', :formatter => :currency_without_sign

          column_format :label,          :order => -1,       :formatter => :not_set_on_blank 
          column_format :value,          :class => 'right',  :formatter => :integer_with_delimiter
          column_format :events,         :class => 'right',  :formatter => :integer_with_delimiter
        
          column_format :referrer_host,  :order => -1, :formatter => :not_set_on_blank   
          column_format :page_title,     :order => -1, :formatter => :not_set_on_blank   
          column_format :region,         :order => 1 #, :formatter => :not_set_on_blank
          column_format :locality,       :order => 2 #, :formatter => :not_set_on_blank
          column_format :device,         :class => 'left', :formatter => :not_set_on_blank             
          column_format :flash_version,  :class => 'left', :formatter => :not_set_on_blank
          column_format :email_client,   :class => 'left', :formatter => :not_set_on_blank              
          column_format :visitors,       :total => :sum, :order => 5, :class => 'visitors right'

          column_format :percent_of_visits,      :total => :sum, :order => 97, :formatter => :bar_and_percentage
          column_format :percent_of_page_views,  :total => :sum, :order => 96, :class => 'page_views', :formatter => :bar_and_percentage 
          column_format :percent_of_impressions, :total => :sum, :order => 23, :class => 'page_views', :formatter => :bar_and_percentage 
          column_format :bounce_rate,            :total => :avg, :order => 101,:class => 'right', :formatter => :percentage
          column_format :exit_rate,              :total => :avg, :order => 98, :class => 'right', :formatter => :percentage  
          column_format :entry_rate,             :total => :avg, :order => 97, :class => 'right', :formatter => :percentage
          column_format :new_visit_rate,         :total => :avg, :order => 100,:class => 'right', :formatter => :percentage
          column_format :page_views_per_visit,   :total => :avg, :order => 99, :class => 'right', :formatter => :float_with_precision  

          column_format :length_of_visit,        :order => -1, 
                       :formatter => lambda{|val, options| "#{val} #{I18n.t('datetime.prompts.second').downcase}" }  
        
          column_format :visit_type,  :order => -1,
                       :formatter => lambda {|val, options| 
                         return val if options[:cell_type] == :th
                         I18n.t("reports.visit_types.#{val}", :default => val) 
                       }
                       
          column_format :attribute, :formatter => lambda {|val, options| 
                         return val if options[:cell_type] == :th
                         I18n.t("activerecord.attributes.track.#{val}", :default => val) 
                       }             
          
          column_format :first_impression_distance, :order => 5, :total => :avg,
                      :formatter => lambda {|val, options|
                         distance_of_time_in_words(val.to_i)
                       }
        
          column_format :country,     :order => 0,
                       :formatter => lambda {|val, options| 
                            return val if options[:cell_type] == :th
                            return I18n.t('tables.not_set') if val.blank?
                            # TODO Country should have a lookup because they do change
                            val = 'RS' if val == 'YU'
                            flag = "<img src=/images/flags/#{val.downcase}.png class='flag' >"
                            country = I18n.t("countries.#{val}", :default => val)
                            return "#{flag} #{country}" 
                       }
                     
          column_format :browser,      :order => -1, 
                       :formatter => lambda {|val, options| 
                            return val if options[:cell_type] == :th
                            return I18n.t('tables.not_set') if val.blank?
                            browser = "<img src='/images/browsers/#{val.downcase}(12x12).png' class='browser' >"
                            return "#{browser} #{val}" 
                       }
                     
          column_format :os_name,      :order => -1,
                       :formatter => lambda {|val, options| 
                           return val if options[:cell_type] == :th
                           return I18n.t('tables.not_set') if val.blank?
                           browser = "<img src='/images/os/#{val.downcase}(12x12).png' class='browser' >"
                           return "#{browser} #{val}" 
                       }
                                     
          column_format :category,
                       :formatter => lambda {|val, options| options[:cell_type] == :th ? val : I18n.t("reports.categories.#{val}", :default => val.titleize) }
          
          column_format :action,
                       :formatter => lambda {|val, options| options[:cell_type] == :th ? val : I18n.t("reports.actions.#{val}", :default => val.titleize) }
        
          column_format :language, :order => -1,
                       :formatter => lambda {|val, options|
                          return I18n.t('tables.not_set') if val.blank?
                          I18n.t("language.#{val}", :default => val)
                       }
                       
          column_format :dialect, :order => 5,
                       :formatter => lambda {|val, options|
                         return I18n.t('tables.not_set') unless val
                         I18n.t("locale.dialect.#{val}", :default => val)
                       }        

          column_format :referrer_category, :order => 1,
                       :formatter => lambda {|val, options|
                         return I18n.t('tables.not_set') unless val
                         I18n.t("reports.referrer_categories.#{val}", :default => val)
                       }
                                            
          column_format :color_depth, :class => 'left',
                       :formatter => lambda { |val, options| 
                          if options[:cell_type] == :th
                            val
                          else
                            val.blank? ? I18n.t('unknown') : "#{val} #{I18n.t('bits')}"
                          end
                       }

          column_format :traffic_source,   :order => 0,
                       :formatter => lambda {|val, options| 
                         return val if options[:cell_type] == :th
                         return I18n.t('tables.not_set') if val.blank?
                         I18n.t("reports.traffic_sources.#{val}", :default => val)
                       }
        end
      end
    end
  end
end                