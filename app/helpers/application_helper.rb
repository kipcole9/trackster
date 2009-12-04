# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tracker_script
    tracker_code = Trackster::Config.tracker
    tracker_cid = current_user.email if logged_in?
    tracking_script = "tracker = new _tks('#{tracker_code}');"
    tracking_script << "\ntracker.setCid('#{tracker_cid}');" if tracker_cid
    tracking_script << "\ntracker.trackPageview();"
    tracking_script
  end

end

