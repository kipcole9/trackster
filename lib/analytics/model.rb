module Analytics
  module Model
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module InstanceMethods  
      def campaign_summary(params)
        tracks.distribution.impressions.clicks_through.campaign_bounces.unsubscribes.by(:name)\
          .between(Track.period_from_params(params))
      end

      def visit_summary(params)
        tracks.visits.event_count.by(params[:action]).between(Track.period_from_params(params))
      end

      def content_summary(params)
        tracks.page_views(:with_events).page_duration.bounce_rate.exit_rate.entry_rate.by(params[:action])\
          .order('page_views DESC').between(Track.period_from_params(params))
      end
      
      def site_summary(params)
        tracks.visits.page_views_per_visit.duration.new_visit_rate.bounce_rate.by(params[:action])\
          .having('visits > 0').order('visits DESC').between(Track.period_from_params(params))
      end
      
      def page_views_by_date(params)
        tracks.page_views.by(:date).between(Track.period_from_params(params))
      end
      
      def page_views_by_url(params)
        tracks.page_views(:with_events).by(:url).order('page_views DESC').limit(10).between(Track.period_from_params(params))
      end
      
      def total_page_views(params)
        tracks.page_views.between(Track.period_from_params(params)).first.page_views
      end
      
      def page_views_by_day(params)
        tracks.page_views.by(:day).between(Track.period_from_params(params))
      end
      
      def visits_by_referrer(params)
        tracks.visits.by(:referrer_host).order('visits DESC').between(Track.period_from_params(params))
      end
      
      def visits_by_search_terms(params)
        tracks.visits.by(:search_terms).order('visits DESC').between(Track.period_from_params(params))
      end
      
      def visits_by_date(params)
        tracks.visits.by(:date).between(Track.period_from_params(params))
      end
      
      def total_referrers(params)
        tracks.visits.filter('referrer_host IS NOT NULL').between(Track.period_from_params(params)).first.visits
      end
      
      def total_visits(params)
        tracks.visits.between(Track.period_from_params(params)).first.visits
      end
    end
    
    module ClassMethods
      
    end
  end
end