Given /^I use the (.+) account$/ do |account|
  params = {
    "name"=> account
  }
  @current_account = Account.create!(params)
  AccountUser.new
  host! "#{account}.example.com"
end

Given /^I am the registered user (.+)$/ do |login|
  params = {
    "email"=> login,
    "password"=>"password",
    "password_confirmation"=>"password"
  }
  @user = @current_account.users.new(params)
  @user.save_without_session_maintenance
end

When /^I login with valid credentials$/ do
  fill_in('email', :with => @user.email)
  fill_in('password', :with => "password")
  click_button("Login")
end
