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
          .between(Track.period_from_params(params)).all
      end

      def visit_summary(params)
        tracks.visits.event_count.by(params[:action]).between(Track.period_from_params(params)).all\
          .sort{|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
      end

      def content_summary(params)
        tracks.page_views(:with_events).page_duration.bounce_rate.exit_rate.entry_rate.by(params[:action])\
          .order('page_views DESC').between(Track.period_from_params(params)).all
      end
      
      def site_summary(params)
        tracks.visits.page_views_per_visit.duration.new_visit_rate.bounce_rate.by(params[:action])\
          .having('visits > 0').order('visits DESC').between(Track.period_from_params(params)).all
      end
    end
    
    module ClassMethods
      
    end
  end
end