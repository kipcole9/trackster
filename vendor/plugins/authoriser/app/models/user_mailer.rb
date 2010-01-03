class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += I18n.t('please_activate', :default => "Please activate your account.")
    @body[:url]  =  activate_url(user.perishable_token)

  end
  
  def activation(user)
    setup_email(user)
    @subject    += I18n.t('account_activated', :login => user.name, :default => "Your account has been activated.")
    @body[:url]  = root_url
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
