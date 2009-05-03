class ValidationsController < ApplicationController
  before_filter     :get_parameters
  
  def unique
    find_options = {:conditions => [ "LOWER(#{@attribute}) LIKE ?", @value.downcase ]}
    if model_class.find(:first, find_options)
      return_response(:not_found, "'#{@value}' #{I18n.t('activerecord.errors.messages.taken')}")
    else
      return_response(:ok)
    end
  end
  
  def validations
    instance = model_class.new
    instance.account_id = current_account.id if current_account rescue nil
    instance.send "#{@attribute}=", @value
    if !instance.valid? && errors = instance.errors.on(@attribute)
      error_message = errors.is_a?(Array) ? errors.first : errors
      value = @value.blank? ?  model_class.human_attribute_name(@attribute) : safe_value
      return_response(:not_found, "'#{value}' #{error_message}")
    else
      return_response(:ok)
    end
  end
  
private
  def safe_value
    if @attribute =~ /.*password.*/i
      model_class.human_attribute_name(@attribute)
    else
      @value
    end
  end

  def return_response(status, message = "")
    RAILS_DEFAULT_LOGGER.debug "Validations returning message: '#{message}'."
    render :json => {:id =>  "#{@id}", :message => message}, :status => status, :layout => false
  end

  def get_parameters
    rejects = ["action","controller","format"]
    value = params.reject{|k, v| rejects.include?(k)}
    models = []
    
    # Build a stack of the possibly nested models that lead
    # to the target attribute
    while contents(value).is_a?(Hash)
      key, value = first_key(value)
      models << key
    end
    
    # Discard row_id => when nested forms.  A row_id is a Fixnum so
    # easy to identify
    if models.last =~ /\d+/ 
      row_id = models.last
      model = models[-2]
    else
      model = models.last
    end
    model = model.gsub(/_attributes$/,'').singularize
    
    # Now we can derive the relevant model info so we can instantiate a model instance
    # and run validations 
    method, value = first_key(value)
    
    # We need to return error messages to the client app.  So we need to know the
    # DOM id of the attribute to return
    # @id = URI.unescape(request.request_uri).split('?')[1].split('=')[0].gsub('][','_').gsub('[','_').gsub(']','')
    @id = [models, method].flatten.join('_')
    
    RAILS_DEFAULT_LOGGER.debug "Validations Controller: Returning #{model}, #{method}, #{value}, #{@id}"
    @model, @attribute, @value = model, method, value
  end
  
  # Hash, being unordered in Ruby 1.8, has no #first method
  # so we have to #each and return the first one    
  def contents(params)
    params.each do |k, v|
      return v
    end
  end
  
  # Same as #contents above, except we return the key and value
  def first_key(params)
    params.each do |k, v|
      return k, v
    end
  end
  
  def model_class
    @model.to_s.camelize.constantize
  end

end