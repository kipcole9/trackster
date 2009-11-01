# Create the admin user
namespace :trackster do
  desc "Create production tracker"
  task(:build_tracker => :environment) do
    tracker_directory   = "public/javascripts"
    tracker_template    = "#{tracker_directory}/tracker_template.js"
    tracker_debug       = "#{tracker_directory}/tracker_debug.js"
    tracker_production  = "#{tracker_directory}/tracker.js"
    begin
      if Rails.env == "staging" || Rails.env == "development"
        `sed -e 's/{{SITE}}/#{Trackster::Config.site}:8080/' #{tracker_template} > #{tracker_debug}`
      elsif Rails.env == "production"
        `sed -e 's/{{SITE}}/#{Trackster::Config.site}/;s/console.log/\\/\\/ console.log/' #{tracker_template} > #{tracker_production}`
      end
    rescue Exception => e
      puts "Could not create production tracker: '#{e.message}'"
      run "ls -al #{tracker_directory}"
    end
  end
end