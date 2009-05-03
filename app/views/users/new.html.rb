@user ||= User.new
panel t('panels.user'), :flash => true, :display_errors => 'user'  do
  block do
    caerus_form_for @user do |user|
      fieldset t('.new_user') do
        user.text_field       :login
        user.text_field       :name
        user.text_field       :email
      end
      fieldset t('type_of_new_user') do
        if current_user.has_role?(Role::ADMIN_ROLE)
          user.select :account_id, Account.find(:all).map{|a| [a.name, a.id]}, :selected => current_user.account.id
        end
        user.select :role, Role.available_roles(current_user), :selected => Role::USER_ROLE
      end
      submit_combo
    end
  end
end