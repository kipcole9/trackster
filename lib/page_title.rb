module PageTitle
  SINGULAR_ACTIONS = ['edit', 'show']
  def self.included(base)
    base.send :helper_method, :page_subject, :page_title if base.respond_to? :helper_method
  end

protected
  def page_title
    action = params['original_action'] || params['action']
    controller_name = params['controller'].singularize
    text = page_subject || ''
    if action == 'index'
      default = "#{controller_name.titleize} #{action.titleize}"
    else
      default = "#{action.titleize} #{controller_name.titleize} #{text}".strip
    end        
    I18n.t("page.#{controller_name}.#{action}", :default => default, :text => text)
  end

  def page_subject=(t)
    @page_subject = t
  end

  def page_subject
    @page_subject
  end

end