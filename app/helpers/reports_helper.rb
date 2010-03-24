module ReportsHelper
  def list_id(list)
    "list_#{list['id']}"
  end
  
  def list_member_id(list)
    "listMember_#{list['id']}"
  end

  def report_params(options = {})
    options.stringify_keys!
    ['campaign', 'time_group', 'from', 'to', 'by', 'period'].each do |arg|
      if ['from', 'to'].include?(arg)
        options[arg] = params[arg].to_date.to_s(:db) if params[arg] && !params['period']
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
    if resource.is_a?(Account)
      send("account_report_path", report_type, params)
    else
      send("#{resource.class.name.downcase}_report_path", resource.id, report_type, params)
    end
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
  
  # Summarise an AR collection by collapsing all records that are
  # less than a given percentage of the total down to an "other"
  # row that is added to the collection
  def collapse_data(data, label_column, value_column, options = {})
    default_options = {:min_percent => 0.05}
    options = default_options.merge(options)
    other = 0; new_data = []    
    total_data = data.inject(0) {|sum, row| sum += row[value_column].to_f}
    data.sort! {|a, b| a[value_column] <=> b[value_column]}.reverse!
    data.each do |i|
      if (i[value_column].to_f / total_data) >= options[:min_percent]
        new_data << i
      else
        other = other + i[value_column].to_f
      end
    end
    new_track = Track.new
    new_track[label_column] = I18n.t("reports.other_#{label_column.to_s}")
    new_track[value_column] = other
    new_data << new_track
  end  
end
