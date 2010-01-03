class RedirectsController < TracksterResources
  respond_to          :html, :xml, :json
  belongs_to          :property
  
  def create
    create! do |success, failure|
      success.html {redirect_back_or_default}
    end
  end
  
  def update
    update! do |success, failure|
      success.html {redirect_back_or_default}
    end
  end
  
  # This is the redirector.  It does as little as possible to ensure
  # speedy response.  Note that the web server will have a log record
  # for this interaction which the log parsing task will pick up and 
  # resolve for us.
  def redirect
    if !params[:redirect].blank? && redirection = Redirect.find_by_redirect_url(params[:redirect])
      query_string = URI.parse(request.url).query rescue nil
      redirect = query_string.blank? ? redirection.url : "#{redirection.url}?#{query_string}"
      redirect_to redirect
    elsif params[:redirect].blank?
      Rails.logger.warn "[Redirect] Redirect with no parameter requested."
      head :status => 404
    else
      Rails.logger.warn "[Redirect] Unknown redirection requested: #{params[:redirect]}"
      head :status => 404
    end
  end

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @redirects ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end

end
