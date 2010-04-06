class HistoryObserver < ActiveRecord::Observer
  observe :contact, :person, :organization, :website, :phone, :address, :email, :note, :campaign, :property, :account, :background

  def before_update(record)
    History.record(record, :update)
  end
  
  def after_create(record)
    History.record(record, :create)
  end
  
  def after_destroy(record)
    History.record(record, :delete)
  end
end
