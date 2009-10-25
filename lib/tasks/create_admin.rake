# Create the admin user
namespace :trackster do
  desc "Create the admin user"
  task(:create_roles => :environment) do
    Role.ensure_roles_exist
  end
  
  desc "Create the admin account"
  task(:create_admin_account => :create_roles) do
    Account.ensure_admin_exists
  end

  desc "Create the admin user"
  task(:create_admin => :create_admin_account) do
    if User.admin_user
      puts "Admin user already exists"
    else
      User.ensure_admin_exists
    end
  end

end