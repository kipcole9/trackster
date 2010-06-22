class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject     += I18n.t('please_activate')
    @body[:url]  =  activate_url(user.perishable_token)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += I18n.t('account_activated', :login => user.name)
    @body[:url]  = root_url
  end

  def password_reset_instructions(user)  
    setup_email(user)
    @subject       += "Password Reset Instructions"  
    @body[:url]    = edit_password_reset_url(user.perishable_token)  
  end
    
protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = Trackster::Config.activation_email
    @subject     = Trackster::Config.activation_subject
    @sent_on     = Time.now
    @body[:user] = user
  end
end
