caerus_form_for @account, :html => { :multipart => true } do |account|
  fieldset t('accounts.account') do
    if @account.new_record?
      account.text_field   :name, :validate => :validations
    else
      account.text_field   :name, :disabled => 'disabled'
    end
    account.text_area    :description
    account.text_field   :tracker, :disabled => 'disabled' unless @account.new_record?
  end
  fieldset t('accounts.email_config') do
    account.text_field    :email_from_name
    account.text_field    :email_from
    account.text_field    :email_reply_to_name
    account.text_field    :email_reply_to
    account.text_field    :unsubscribe_url 
  end
  fieldset t('accounts.presentation') do
    account.text_field    :theme
    store image_tag(@account.logo(:banner)) if @account.logo?
    account.file_field    :logo
  end
  fieldset t('accounts.advanced_options') do
    account.text_field    :custom_domain, :validate => :validations
  end
  submit_combo
end