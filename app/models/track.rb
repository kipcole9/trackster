class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaigns

  NON_METRIC_KEYS = [:scoped, :source, :between, :by, :duration, :campaign, :medium, :source, :order, :label, :filter]
  NON_NULL_DIMENSIONS = [:referrer, :search_terms, :referrer_host, :language]
    
  include Analytics::Metrics
  include Analytics::Dimensions
  include Analytics::ParamParser
  extend ActionView::Helpers::NumberHelper
  
  table_format :language,   :order => -1,
               :formatter => lambda {|val, options| val.blank? ? I18n.t('not_set') : val}
  table_format :country,    :order => -1,
               :formatter => lambda {|val, options| val.blank? ? I18n.t('not_set') : val}
  table_format :os_name,    :order => -1,
               :formatter => lambda {|val, options| val.blank? ? I18n.t('not_set') : val}               
  table_format :browser,    :order => -1,
               :formatter => lambda {|val, options| val.blank? ? I18n.t('unknown') : val}
  table_format :visit_type,  :order => -1,
               :formatter => lambda {|val, options| options[:cell_type] == :th ? val : I18n.t("properties.site_summary.#{val}") }
      
  table_format :count,      :total => :sum, :order => 99
  table_format :page_views, :total => :sum, :class => 'page_views right', :order => 99
  table_format :visits,     :total => :sum, :class => 'right', :order => 50, :formatter => lambda{|num, options| num.to_i.to_s}
  table_format :duration,   :total => :avg, :class => 'right', :order => 60,
               :formatter => lambda {|val, options|
                  minutes = val / 60
                  hours = val / 3600
                  seconds = val - (hours * 3600) - (minutes * 60)
                  "#{"%02d" % hours}:#{"%02d" % minutes}:#{"%02d" % seconds}"
               }
  
  table_format :color_depth, :class => 'left',
               :formatter => lambda{ |val, options| 
                  if options[:cell_type] == :th
                    val
                  else
                    val.blank? ? I18n.t('unknown') : "#{val} #{I18n.t('bits')}"
                  end
                }
  
  table_format :device, :class => 'left',
               :formatter => lambda{|val, options| val.blank? ? I18n.t('not_set') : val}             
  
  table_format :flash_version, :class => 'left',
               :formatter => lambda{|val, options| (val.blank? || val == '-') ? I18n.t('not_set') : val}
                 
  table_format :bounce_rate, :order => 101, :class => 'right',
               :total => :avg,
               :formatter => lambda{|num, options| self.number_to_percentage(num ? (num.to_f * 100) : 0, :precision => 1) }
               
  table_format :new_visit_rate, :order => 100, :class => 'right',
               :total => :avg,
               :formatter => lambda{|num, options| self.number_to_percentage(num ? (num.to_f * 100) : 0, :precision => 1) }
               
  table_format :page_views_per_visit, :class => 'right', 
               :total => :avg, :order => 99,
               :formatter => lambda{|num, options| number_with_precision(num.to_f, :precision => 1) }
  
  table_format :visitors,   :total => :sum, :class => 'visitors right', :order => 99
  
  table_format :percent_of_visits, :total => :sum, :class => 'right', :order => 98, 
               :formatter => lambda{|num, options| self.number_to_percentage(num, :precision => 1) }
               
  table_format :percent_of_page_views, :total => :sum, :class => 'page_views', :order => 98, 
               :formatter => lambda{|num, options| self.bar_formatter(num, options[:cell_type]) }
    
  #chart_format :date,      :formatter => lambda{|date| "#{date.day} #{I18n.t('date.abbr_month_names')[date.month]}"}
  #chart_format :month,     :formatter => lambda{|month| I18n.t('date.abbr_month_names')[month]}
  #chart_format :day,       :formatter => lambda{|day| I18n.t('date.abbr_day_names')[day]}       
  
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
  
  def self.bar_formatter(value, cell_type)
    if cell_type == :td
      bar = "<div class=\"hbar\" style=\"width:#{value}%\">&nbsp;</div>"
      bar + "<div>" + self.number_to_percentage(value, :precision => 1) + "</div>"
    else
      self.number_to_percentage(value, :precision => 1)
    end
  end
end
