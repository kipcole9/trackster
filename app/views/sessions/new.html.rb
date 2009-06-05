column :width => 3 do
  p "&nbsp;"
end
column :width => 6 do
  @user = User.new
  panel t('panels.login'), :flash => true  do
    block do
      caerus_form_for @user, :url => session_path do |user|
        fieldset t('log_in') do
          user.text_field     :login, :no_prompt => true        
          user.password_field :password, :no_prompt => true
          user.check_box      :remember_me?
        end
      
        submit_combo :text => 'login'
      end
    end
  end
end
column :width => 3 do
  p "&nbsp;"
end
