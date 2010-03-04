panel t('panels.new_user'), :flash => true, :display_errors => :user  do
  block do
    caerus_form_for @user || User.new do |user|
      fieldset t('.new_user') do
        user.text_field :email,       :validate => :validations
        user.text_field :given_name,  :validate => :validations
        user.text_field :family_name, :validate => :validations
      end
      fieldset t('.user_roles') do
        User::ROLES.each do |r|
          with_tag(:div) do
            store check_box_tag("roles[]", r, @user.has_role?(r))
            store content_tag(:label, r.humanize, :class => :field_label)
          end
        end
        nil
      end
      submit_combo
    end
  end
end
