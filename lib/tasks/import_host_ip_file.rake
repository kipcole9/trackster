namespace :trackster do

  desc "Import host_ip reverse geocode database"
  task(:import_hostip_database => :environment) do
    puts "Importing the host_ip reverse geocode database.  This will take several minutes."
    if Rails.env == "development"
      config_dir = "#{Rails.root}/tmp"
    else
      config_dir = "/u/apps/trackster/config"
    end
    db = YAML::load(File.open("#{Rails.root}/config/database.yml"))[Rails.env]
    `rsync -avz --progress rsync://hostip.info/hostip/mysql/hip_all.sql #{config_dir}`
    `mysql -D #{db['database']} -u #{db['username']} -p#{db['password']} <#{config_dir}/hip_all.sql`
  end
  
  
end
