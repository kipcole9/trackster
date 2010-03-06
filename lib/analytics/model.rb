module Analytics
  module Model
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
      def campaign_summary(params = {})
        tracks.distribution.impressions.clicks_through.campaign_bounces.unsubscribes.by(:name)\
          .between(Track.period_from_params(params))
      end

      def visit_summary(params = {})
        tracks.visits.page_views.event_count.by(params[:action]).between(Track.period_from_params(params))
      end

      def content_summary(params = {})
        tracks.page_views(:with_events).page_duration.bounce_rate.exit_rate.entry_rate.by(params[:action])\
          .order('page_views DESC').between(Track.period_from_params(params))
      end
      
      def site_summary(params = {})
        tracks.visits.page_views_per_visit.duration.new_visit_rate.bounce_rate.by(params[:action])\
          .having('visits > 0').order('visits DESC').between(Track.period_from_params(params))
      end
      
      def events_summary(params = {})
        tracks.event_count(:with_events).value.by(:label, :category, :action).between(Track.period_from_params(params))
      end
      
      def one_event_summary(params = {})
        tracks.event_count(:with_events).value.by(:action).between(Track.period_from_params(params))
      end
      
      def page_views_by_date(params = {})
        tracks.page_views.by(:date).between(Track.period_from_params(params))
      end
      
      def page_views_by_url(params = {})
        tracks.page_views(:with_events).by(:url).order('page_views DESC').limit(10).between(Track.period_from_params(params))
      end
      
      def total_page_views(params = {})
        tracks.page_views.between(Track.period_from_params(params)).first.page_views
      end
      
      def page_views_by_day(params = {})
        tracks.page_views.by(:day).between(Track.period_from_params(params))
      end
      
      def visits_by_referrer(params = {})
        tracks.visits.by(:referrer_host).order('visits DESC').between(Track.period_from_params(params))
      end
      
      def visits_by_search_terms(params = {})
        tracks.visits.by(:search_terms).order('visits DESC').between(Track.period_from_params(params))
      end
      
      def visits_by_date(params = {})
        tracks.visits.by(:date).between(Track.period_from_params(params))
      end
      
      def visits_by_day_of_week(params = {})
        tracks.average_visits.by(:day_of_week).between(Track.period_from_params(params))
      end
      
      def visits_by_hour(params = {})
        tracks.average_visits.by(:hour).between(Track.period_from_params(params))
      end
      
      def total_referrers(params = {})
        tracks.visits.filter('referrer_host IS NOT NULL').between(Track.period_from_params(params)).first.visits
      end
      
      def total_visits(params = {})
        tracks.visits.between(Track.period_from_params(params)).first.visits
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
        tracks.video_views.filter(conditions).between(Track.period_from_params(params)).by(:max_play_time)
      end
    end
    
    module ClassMethods
      
    end
  end
end