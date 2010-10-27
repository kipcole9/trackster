# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tracking_script
    case Rails.env 
    when "development"
      # store "<script src='http://admin.trackster.local/_tks.js' type='text/javascript' ></script>"
      # store tracker_call
    when "staging"
      store "<script src='http://traphos.com:8080/_tks.js' type='text/javascript' ></script>"
    else
      store "<script src='http://traphos.com/_tks.js' type='text/javascript' ></script>"
      tracker_call
    end
  end
  
  def tracker_call
    user_identity = User.current_user['id'] if logged_in?
    @set_user = user_identity ? "tracker.setId(#{user_identity});" : ""
    include "widgets/tracker_call"
  end  

  def time_group
    params[:time_group] || 'date'
  end
  
  def time_period
    Period.from_params(params)
  end
  
  def time_group_t
    t "reports.time_group.#{time_group}", :default => time_group.humanize
  end
  
  def time_period_t_for_graph
    time_group == 'year' ? '' : time_period_t
  end
  
  def time_period_t
    Period.in_text_from_params(params)
  end

  def current_action
    params['action']
  end
  
  def dimension_label(options)
    t("reports.#{options.first[1]}")
  end

  def select_media
    params[:print] ? 'screen, print' : 'print'
  end
  
  def print_button
    "<img src=/images/icons/printer.png id=print alt=\"#{I18n.t('printer_friendly')}\" title=\"#{I18n.t('printer_friendly')}\">"
  end
  
  def save_page_load_start
    javascript "var startLoad = (new Date).getTime();"
  end

end

