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
  authorize_resource
  
  class Trackster::Responder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder
    include Responders::XhrResponder    
  end

  def update
    update! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end
  
  def create
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

  def responder
    Trackster::Responder
  end
  
end