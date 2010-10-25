module Trackster
  module PageTitle
    def self.included(base)
      base.send :helper_method, :page_subject, :page_title if base.respond_to? :helper_method
      base.memoize :page_title if base.respond_to? :memoize
    end

    def page_title
      resource_name = (resource rescue nil) ? resource.name.strip_tags.titleize : ''
      action_name = resource_name.blank? ? action : "#{action}_resource"
      key = "page_title.#{controllername}.#{action_name}"
      I18n.t(key,:default  => default_page_title, :resource => resource_name, :account  => current_account.name)
    end

    
    def default_page_title
      if action == 'index'
        default = "#{controllername.singularize.titleize} #{action.titleize}"
      else
        default = "#{action.titleize} #{controllername.singularize.titleize}"
      end      
    end

    def page_subject=(subject)
      @page_subject = subject || ''
    end

    def page_subject
      @page_subject
    end

  end
end