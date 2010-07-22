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
  unloadable
  authorize_resource
  respond_to          :html, :xml, :json
  respond_to          :csv, :only => :index
  respond_to          :all do
    format_not_found
  end
  
  class Trackster::Responder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder
    include Responders::XhrResponder   
  end
  
  def index
    index! do |success|
      success.csv { render :text => collection.to_csv }
    end
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
  
  def to_csv
    raise "CSV"
  end
  
private
  def begin_of_association_chain
    current_account
  end
  
end