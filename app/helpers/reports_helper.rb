module ReportsHelper
  
  def list_id(list)
    "list_#{list['id']}"
  end
  
  def list_member_id(list)
    "listMember_#{list['id']}"
  end

  def report_params(additional_params = {})
    new_params = {}
    [:from, :to, :period, :time_group, :campaign].each do |param|
      new_params[param] = params[param] if params[param]
      new_params[param] = additional_params[param] if additional_params[param]
    end
    new_params.delete_if {|k, v| [:from, :to].include?(k) } if new_params[:period]
    new_params
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
  
  def report_path(resource, report_type, additional_params)
    if resource.is_a?(Account)
      path = send("account_report_path", report_type, additional_params)
    else
      path = send("#{resource.class.name.downcase}_report_path", resource, report_type, additional_params)
    end
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
    new_track[label_column] = I18n.t("reports.other_#{label_column.to_s}", :default => "Other")
    new_track[value_column] = other
    new_data << new_track
  end 
  
  def report_cache_key(prefix)
    "#{prefix}/#{current_account['id']}/#{current_user['id']}/#{Trackster::Theme.current_theme}-#{I18n.locale}-#{params[:period] || 'p'}-#{params[:time_group] || 't'}"
  end 
end
