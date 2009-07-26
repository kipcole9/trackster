module PropertiesHelper
  def list_id(list)
    "list_#{list['id']}"
  end
  
  def list_member_id(list)
    "listMember_#{list['id']}"
  end

  def report_params(options = {})
    ['between', 'campaign', 'tgroup', 'from', 'to', 'by'].each do |arg|
      options[arg] = params[arg] if params[arg]
    end
    options
  end
  
  # Navigation link to a specfic report.  Translate the report type a the label,
  # apply any additional parameters
  def property_report(report_type, additional_params = {})
    link_to t("property_report.#{report_type}"), property_report_path(@property, report_type, report_params(additional_params))
  end
  
  def add_dimension(report_type, additional_params = {})
    link_to dimension_label(additional_params), property_report_path(@property, report_type, report_params(additional_params))    
  end
  
  def current_action
    params['action']
  end
  
  def dimension_label(options)
    options.each do |k, v| 
      return t("property_report.#{v}")
    end
  end
end
