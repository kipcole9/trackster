class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://vietools.com/activate/#{user.activation_code}"

  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://vietools/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "activation@videoinemail.com"
      @subject     = "[vietools activation] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
