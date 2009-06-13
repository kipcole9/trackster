@user.password = @user.password_confirmation = nil
clear do
  column :width => 8 do
    panel 'accounts.new_account.signup' do
      store error_messages_for :account, :user, :class => "block", :header_tag => :h6
      block do
        caerus_form_for @account, :url => account_path do |a|
          caerus_fields_for @user do |u|
            section(:class => :section_left) do
              fieldset('accounts.new_account.user_info') do
                u.text_field :first_name, :validate => "validations", :focus => true, :size => 30
                u.text_field :last_name, :validate => "validations", :size => 30
                u.text_field :email, :size => 30, :validate => "validations"
              end
        
              fieldset('accounts.new_account.request_login_info') do
                u.text_field :login, :validate => "validations", :size => 20
                u.password_field :password, :validate => "validations", :size => 20
                u.password_field :password_confirmation, :validate => "validations", :size => 20
              end
            end  
        
            section(:class => :section_right) do
              fieldset('accounts.new_account.account_info') do
                a.text_field :name, :validate => "validations", 
                  :before => "<div class='sitename'>http://", 
                  :after => ".#{I18n.t(:site_name)}</div>", :size => 9
              end
      
              fieldset('accounts.new_account.preferences') do 
                u.select :locale, [["English", 'en-US'],["French", 'fr']]
                u.time_zone_select :timezone, time_zones_like(Time.zone), :default => Time.zone.name
              end
            end  
            submit_combo :text => 'accounts.new_account.submit_sign_up', :id => "new_account_button", :back => root_url   
          end
        end
      end
    end
  end
  
  column :width => 4 do
    include 'new_account_help'
  end
end