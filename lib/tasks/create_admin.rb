# Create the admin user
namespace :trackster do
  desc "Create the admin user"
  task(:analyse_log => :environment) do
    if User.admin_user
      puts "Admin user already exists"
    else
      User.create!( 
        :family_name => "Administrator", 
        :login => 'admin', 
        :password => 'admin123', 
        :password_confirmation => 'admin123',
        :state => 'action',
        :email => (Trackster::Config.admin_email_address || 'admin@traphos.com')
      )
    end
  end

end