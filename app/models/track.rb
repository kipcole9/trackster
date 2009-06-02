class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaign

  NON_METRIC_KEYS = [:scoped, :source, :between, :by, :duration, :order, :label, :filter, :limit, :having]
  NON_NULL_DIMENSIONS = [:referrer, :search_terms, :referrer_host, :campaign_name, :local_hour]
    
  include Analytics::Metrics
  include Analytics::Dimensions
  include Analytics::ParamParser
  
  table_format :count,          :total => :sum, :order => 99
  table_format :event_count,    :order => 20
  table_format :impressions,    :total => :sum, :order => 1, :class => 'right', :formatter => :number_with_delimiter
  table_format :clicks_through, :total => :sum, :order => 2, :class => 'right', :formatter => :number_with_delimiter
  table_format :distribution,   :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
  table_format :bounces,        :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
  table_format :unsubscribes,   :total => :sum, :class => 'right', :formatter => :integer_with_delimiter
  table_format :page_views,     :total => :sum, :order => 99, :class => 'page_views right'
  table_format :visits,         :total => :sum, :order => 50, :class => 'right'
  table_format :page_views,     :total => :sum, :order => 50, :class => 'right'
  table_format :duration,       :total => :avg, :order => 90, :class => 'right', :formatter => :seconds_to_time
  table_format :hour,           :total => :avg, :order => 90, :class => 'right', :formatter => :hours_to_time
    
  table_format :referrer_host,  :order => -1, :formatter => :not_set_on_blank   
  table_format :page_title,     :order => -1, :formatter => :not_set_on_blank   
  table_format :language,       :order => -1, :formatter => :not_set_on_blank
  table_format :country,        :order => 0,  :formatter => :not_set_on_blank
  table_format :region,         :order => -1, :formatter => :not_set_on_blank
  table_format :locality,       :order => -2, :formatter => :not_set_on_blank
  table_format :os_name,        :order => -1, :formatter => :not_set_on_blank 
  table_format :device,         :class => 'left', :formatter => :not_set_on_blank             
  table_format :flash_version,  :class => 'left', :formatter => :not_set_on_blank               
  table_format :browser,        :order => -1, :formatter => :unknown_on_blank
  table_format :visitors,       :total => :sum, :order => 99, :class => 'visitors right'

  table_format :percent_of_visits,      :total => :sum, :order => 98, :formatter => :bar_and_percentage
  table_format :percent_of_page_views,  :total => :sum, :order => 98, :class => 'page_views', :formatter => :bar_and_percentage 
  table_format :bounce_rate,            :total => :avg, :order => 101, :class => 'right', :formatter => :percentage
  table_format :exit_rate,              :total => :avg, :order => 97, :class => 'right', :formatter => :percentage  
  table_format :entry_rate,             :total => :avg, :order => 96, :class => 'right', :formatter => :percentage
  table_format :new_visit_rate,         :total => :avg, :order => 100, :class => 'right', :formatter => :percentage
  table_format :page_views_per_visit,   :total => :avg, :order => 99, :class => 'right', :formatter => :float_with_precision  
  
  table_format :length_of_visit,        :order => -1, 
               :formatter => lambda{|val, options| "#{val} #{I18n.t('datetime.prompts.second').downcase}" }  
  table_format :visit_type,  :order => -1,
               :formatter => lambda {|val, options| options[:cell_type] == :th ? val : I18n.t("properties.site_summary.#{val}") }
      
  table_format :color_depth, :class => 'left',
               :formatter => lambda{ |val, options| 
                  if options[:cell_type] == :th
                    val
                  else
                    val.blank? ? I18n.t('unknown') : "#{val} #{I18n.t('bits')}"
                  end
                }

  table_format :traffic_source,   :order => 0,
               :formatter => lambda {|val, options| 
                 if options[:cell_type] == :th
                   val
                 else
                   val.blank? ? I18n.t('not_set') : I18n.t("properties.site_summary.#{val}", :default => val)
                 end
                }

  named_scope :having, lambda {|having| {:having => having} }
  named_scope :limit, lambda {|limit| {:limit => limit} }
  named_scope :order, lambda {|order| {:order => order} }       
  named_scope :filter, lambda {|conditions| {:conditions => conditions} }
  named_scope :property, lambda {|property|
    if property.is_a?(Property)
      { :conditions => ["property_id = ?", property.id] } 
    else
      { :conditions => ["property_id = ?", Property.find_by_name(property).try(:id)] } 
    end
  }
  
end
