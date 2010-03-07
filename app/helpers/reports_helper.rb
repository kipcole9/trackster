module ReportsHelper
  def list_id(list)
    "list_#{list['id']}"
  end
  
  def list_member_id(list)
    "listMember_#{list['id']}"
  end

  def report_params(options = {})
    ['campaign', 'time_group', 'from', 'to', 'by', 'period'].each do |arg|
      if ['from', 'to'].include?(arg)
        options[arg] = params[arg].to_date.to_s(:db) if params[arg]
      else
        options[arg] = params[arg] if params[arg]
      end
    end
    options
  end
  
  # Navigation link to a specfic report.  Translate the report type a the label,
  # apply any additional parameters
  def report_link(report_type, additional_params = {})
    link_to t("reports.name.#{report_type}", :time_period => nil).strip, report_path(resource, report_type, report_params(additional_params))
  end
  
  def video_report(name, additional_params = {})
    link_to t("reports.name.video_item", :name => name), report_path(resource, "video", report_params(additional_params))
  end
  
  def add_dimension(report_type, additional_params = {})
    link_to dimension_label(additional_params), report_path(resource, report_type, report_params(additional_params))    
  end
  
  def report_path(resource, report_type, params)
    send("#{resource.class.name.downcase}_report_path", resource.id, report_type, params)
  end

  def time_group
    @time_group ||= params[:time_group] || 'date'
  end
  
  def time_period
    @time_period ||= Track.period_from_params(params)
  end
  
  def time_group_t
    t "reports.time_group.#{time_group}", :default => time_group.humanize
  end
  
  def time_period_t_for_graph
    time_group == 'year' ? '' : time_period_t
  end
  
  def time_period_t
    Track.period_in_text_from_params(params)
  end

  def current_action
    params['action']
  end
  
  def dimension_label(options)
    t("reports.#{options.first[1]}")
  end
end
