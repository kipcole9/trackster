module Responders
  module XhrResponder
    def initialize(controller, resources, options={})
      super
    end

    def to_html
      request.xhr? ? render(:partial => "#{controller.params[:action]}") : super
    end
  end
end


class TracksterResources < InheritedResources::Base
  
  class Trackster::Responder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder
    include Responders::XhrResponder    
  end


  def responder
    Trackster::Responder
  end
  
end