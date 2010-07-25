class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject     += I18n.t('authorizer.please_activate')
    @body[:url]  =  activate_url(user.perishable_token)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += I18n.t('authorizer.account_activated', :login => user.name)
    @body[:url]  = root_url
  end

  def password_reset_instructions(user)  
    setup_email(user)
    @subject       += I18n.t('authorizer.password_reset_instructions')
    @body[:url]    = edit_password_reset_url(user.perishable_token)  
  end
  
  def added_to_account_notification(account, user)
    setup_email(user)
    @subject       += I18n.t("authorizer.added_to_account", :name => account.name)
    @body[:url]    = root_url
  end
    
protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "noreply@#{root_url.sub('http://', '').sub(/\/\Z/,'')}"
    @subject     = "[#{Account.current_account.name}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
