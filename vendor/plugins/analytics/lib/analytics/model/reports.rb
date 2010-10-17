module Analytics
  module Model
    module Reports
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end
    
      # These are the 'reporting' methods.  
      #
      # Each named scoped is a metric that builds up a column of a report. (see Analytics::Metrics)
      # #by method build the dimension we're reporting (see Analytics::Dimensions)
      module InstanceMethods
        def campaign_overview(campaign, params = {})
          tracks.distribution.impressions.clicks_through.campaign_bounces.unsubscribes.by(:campaign_name)\
            .active(campaign).between(Period.from_params(params))
        end
        
        def campaign_impressions(campaign, params = {})
          tracks.impressions.open_rate.deliveries.cost.cost_per_impression.by(:campaign_name)\
            .active(campaign).between(Period.from_params(params))
        end
        
        def campaign_clicks(campaign, params = {})
          tracks.impressions.clicks_through.cost.click_through_rate.cost_per_click.by(:campaign_name)\
            .active(campaign).between(Period.from_params(params))
        end
        
        def email_client_overview(campaign, params = {})
          tracks.impressions.by(:email_client).order('impressions DESC').between(Period.from_params(params)).active(campaign)
        end

        #def visit_summary(params = {})
        #  tracks.visits.page_views.event_count.by(params[:action]).between(Period.from_params(params))
        #end

        def content_summary(params = {})
          tracks.page_views(:with_events).page_duration.bounce_rate.exit_rate.entry_rate.by(params[:action])\
            .order('page_views DESC').between(Period.from_params(params))
        end
      
        def visits_summary(params = {})
          if params[:action] == 'loyalty'
            loyalty(params)
          else
            tracks.visits.page_views_per_visit.duration.new_visit_rate.bounce_rate.by(params[:action])\
              .having('visits > 0').order("visits DESC").between(Period.from_params(params))
          end
        end

        def new_v_returning_summary(params = {})
          tracks.visits.page_views_per_visit.duration.bounce_rate.by(params[:action])\
            .having('visits > 0').order('visits DESC').between(Period.from_params(params))
        end
      
        def entry_exit_summary(params = {})
          tracks.page_views(:with_events).page_duration.by(params[:action])\
            .order('page_views DESC').between(Period.from_params(params))
        end

        def events_summary(params = {})
          tracks.event_count(:with_events).value.by(:label, :category, :action).between(Period.from_params(params))
        end
        
        def event_stream(params = {})
          # tracks.find(:all, :select => "sessions.*, events.*", :joins => :events).between(Period.from_params(params)) 
          tracks.stream.between(Period.from_params(params))            
        end
      
        def one_event_summary(params = {})
          tracks.event_count(:with_events).value.by(:action).between(Period.from_params(params))
        end
      
        # page_views_by_* methods
        def page_views_by_date(params = {})
          tracks.page_views.by(:date).between(Period.from_params(params))
        end
      
        def page_views_by_day_of_month(params = {})
          tracks.page_views.by(:day_of_month).order('day_of_month ASC').between(Period.from_params(params))
        end

        def page_views_by_hour(params = {})
          tracks.page_views.by(:hour).order('hour ASC').between(Period.from_params(params))
        end

        def page_views_by_day_of_week(params = {})
          tracks.page_views.by(:day_of_week).order('day_of_week ASC').between(Period.from_params(params))
        end

        def page_views_by_month(params = {})
          tracks.page_views.by(:year, :month).order('day_of_week ASC').between(Period.from_params(params))
        end

        # No point in applying a date range on a summary by year
        def page_views_by_year(params = {})
          tracks.page_views.by(:year).order('year ASC')
        end

        def page_views_by_url(params = {})
          tracks.page_views(:with_events).by(:url).order('page_views DESC').limit(10).between(Period.from_params(params))
        end
      
        def page_views_by_visit_type(params = {})
          tracks.page_views.by(:visit_type).order('page_views DESC').limit(10).between(Period.from_params(params))
        end
      
        def total_page_views(params = {})
          tracks.page_views.between(Period.from_params(params)).first.page_views
        end  

        def visits_by_referrer(params = {})
          tracks.visits.by(:referrer_host).order('visits DESC').between(Period.from_params(params))
        end
      
        def visits_by_search_terms(params = {})
          tracks.visits.by(:search_terms).order('visits DESC').between(Period.from_params(params))
        end
      
        # Temporal grouping
        def visits_by_date(params = {})
          tracks.visits.by(:date).between(Period.from_params(params))
        end
      
        def visits_by_day_of_week(params = {})
          tracks.average_visits.by(:day_of_week).between(Period.from_params(params))
        end
      
        def visits_by_hour(params = {})
          tracks.average_visits.by(:hour).between(Period.from_params(params))
        end

        def visits_by_day_of_month(params = {})
          tracks.average_visits.by(:day_of_month).between(Period.from_params(params))
        end
      
        def visits_by_month(params = {})
          tracks.average_visits.by(:year, :month).between(Period.from_params(params))
        end
      
        def visits_by_year(params = {})
          tracks.average_visits.by(:year).between(Period.from_params(params))
        end
            
        # Platform grouping
        def visits_by_browser(params = {})
          tracks.visits.by(:browser).between(Period.from_params(params))
        end
      
        def visits_by_device(params = {})
          tracks.visits.by(:device).between(Period.from_params(params))
        end

        def visits_by_os(params = {})
          tracks.visits.by(:os_name).between(Period.from_params(params))
        end

        def visits_by_windows_version(params = {})
          tracks.visits.by(:os_version).filter("os_name = 'Windows'").between(Period.from_params(params))
        end

        def total_referrers(params = {})
          tracks.visits.filter('referrer_host IS NOT NULL').between(Period.from_params(params)).first.visits
        end
      
        def total_visits(params = {})
          tracks.visits.between(Period.from_params(params)).first.visits
        end
      
        def loyalty(params = {})
          period = Period.from_params(params)
          resource_scope = "#{self.class.name.downcase}_id = #{self['id']}"
          tracks.find_by_sql <<-SQL
            select visit_count, count(visitors) as visitors, sum(visit_count) as visits, avg(duration) as duration, avg(page_views) as page_views_per_visit
            from (
              select count(visit) as visit_count, count(visitor) as visitors, avg(duration) as duration, avg(page_views) as page_views
                from sessions 
                where started_at >= '#{period.first.to_s(:db)}' and started_at <= '#{period.last.to_s(:db)}'
                and #{resource_scope}
                group by visitor
            ) as visit_summary
            group by visit_count;
          SQL
        end
      
        def video_labels(params = {})
          conditions = params['video'] ? ["category = 'video' and label = ?", params['video']] : "category = 'video'"
          tracks.find(:all, :select => "DISTINCT label", :conditions => conditions, :order => 'label', :joins => :events).map(&:label)
        end
      
        def video_summary(video, params = {})
          one_event_summary(params).filter(["label = ?", video]).having('event_count > 0')
        end
      
        def video_play_time(params = {})
          conditions = params['video'] ? ["label = ?", params['video']] : ''
          tracks.video_views.filter(conditions).between(Period.from_params(params)).by(:max_play_time)
        end
      end
    
      module ClassMethods

      end
    end
  end
end