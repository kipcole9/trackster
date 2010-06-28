class HistoryObserver < ActiveRecord::Observer
  observe :contact, :person, :organization, :website, :phone, :address, :email, 
          :note, :campaign, :property, :account, :background

  def before_update(record)
    History.record(record, :update) unless rolling_back?
  end
  
  def after_create(record)
    History.record(record, :create) unless rolling_back?
  end
  
  def after_destroy(record)
    History.record(record, :delete) unless rolling_back?
  end

private
  def rolling_back?
    !ActiveRecord::Base.record_timestamps
  end
  
end
