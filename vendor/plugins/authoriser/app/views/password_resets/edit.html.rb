column :before => 3, :width => 6 do
  panel t('panels.reset_password'), :display_errors => :user  do
    block do
      form_for @user, :url => password_reset_path(@user) do |user|
        fieldset t('users.password_reset') do
          user.hidden_field   :perishable_token
          user.password_field :password
          user.password_field :password_confirmation
        end
        submit_combo :text => 'users.update_password_and_login'
      end
    end
  end
end