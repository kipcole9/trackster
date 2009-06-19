@user ||= User.new
panel t('panels.new_user'), :flash => true, :display_errors => 'user'  do
  block do
    caerus_form_for @user do |user|
      fieldset t('.new_user') do
        user.text_field       :login, :validate => :validations
        user.text_field       :given_name, :validate => :validations
        user.text_field       :family_name, :validate => :validations
        user.text_field       :email, :validate => :validations
      end
      fieldset t('.type_of_new_user') do
        if current_user.has_role?(Role::ADMIN_ROLE)
          user.select :account_id, Account.find(:all).map{|a| [a.name, a.id]}, :selected => current_account.id
        end
        user.select :role, Role.available_roles(current_user), :selected => Role::USER_ROLE
      end
      possible_properties
      submit_combo
    end
  end
end

keep :sidebar do
  store render 'sidebar_new'
end
