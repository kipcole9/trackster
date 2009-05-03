namespace :trackster do

  desc "Import host_ip reverse geocode database"
  task(:import_hostip_database => :environment) do
    config_dir = "/u/apps/trackster/config"
    db = YAML::load(File.open("#{Rails.root}/config/database.yml"))[Rails.env]
    `rsync -avz --progress rsync://hostip.moria.org/hostip/mysql/hip_all.sql #{config_dir}`
    `mysql -D #{db.database} -u #{db.username} -p #{db.password} <#{config_dir}/hip_all.sql`
  end
  
  
end
