form_for @account, :html => { :multipart => true } do |account|
  tab "account" do
    tab_item t('accounts.account') do
      if @account.new_record?
        account.text_field   :name, :validate => :validations
      else
        account.text_field   :name, :disabled => 'disabled'
      end
      account.text_area      :description
      account.text_field     :tracker, :disabled => 'disabled' unless @account.new_record?
    end
    tab_item t('accounts.email_config') do
      account.text_field    :email_from_name
      account.text_field    :email_from
      account.text_field    :email_reply_to_name
      account.text_field    :email_reply_to
      account.text_field    :unsubscribe_url 
    end
    tab_item t('accounts.presentation') do
      account.text_field    :theme
      store image_tag(@account.logo(:banner)) if @account.logo?
      account.file_field    :logo
    end
    tab_item t('accounts.advanced_options') do
      account.text_field    :salutation
      account.time_zone_select :timezone, time_zones_like(Time.zone), :include_blank => true       
      account.text_field    :currency_code
      account.text_field    :custom_domain, :validate => :validations
      account.text_field    :ip_filter
    end
  end
  submit_combo
end