class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # UserMailer.deliver_signup_notification(user) unless user.login == 'admin'
  rescue Exception => e
    Rails.logger.error "Could not sent signup email"
    Rails.logger.error e.message
  end

  def after_save(user)
    # UserMailer.deliver_activation(user) if user.recently_activated?
  rescue Exception => e
    Rails.logger.error "Could not sent activation email"
    Rails.logger.error e.message    
  end
end
