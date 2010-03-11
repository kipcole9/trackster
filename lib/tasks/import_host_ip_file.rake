namespace :trackster do

  desc "Import host_ip reverse geocode database"
  task(:import_hostip_database => :environment) do
    puts "Importing the host_ip reverse geocode database.  This will take several minutes."
    config_dir = Trackster::Config.config_dir
    db = YAML::load(File.open("#{Rails.root}/config/database.yml"))[Rails.env]
    `rsync -avz --progress rsync://hostip.info/hostip/mysql/hip_all.sql #{config_dir}`
    `mysql -D #{db['database']} -u #{db['username']} -p#{db['password']} <#{config_dir}/hip_all.sql`
    puts "Importing completed."
  end
  
  
end
