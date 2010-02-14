module Responders
  module XhrResponder
    def initialize(controller, resources, options={})
      super
    end

    def to_html
      if request.xhr?
        render :partial => "#{controller.params[:action]}" rescue super
      else
        super
      end
    end
  end
end


class TracksterResources < InheritedResources::Base
  
  class Trackster::Responder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder
    include Responders::XhrResponder    
  end

  responder = Trackster::Responder
  
end