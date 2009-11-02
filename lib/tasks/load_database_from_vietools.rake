# Create the admin user
namespace :trackster do
  desc "Refresh Database from vietools production"
  task(:refresh_database => :environment) do
    db_name = "trackster_development"
    `mysql -u root -e "drop database #{db_name}"`
    `mysql -u root -e "create database #{db_name}"`
    `mysql -u root #{db_name} < #{Rails.root}/tmp/production_dump.sql`
  end
end