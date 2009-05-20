class TrafficSource < ActiveRecord::Base
  belongs_to              :account 
  validates_associated    :account
  validates_presence_of   :account_id
  validates_uniqueness_of :host, :scope => :account_id
  after_save              :update_sessions
  
private  
  def update_sessions
    self.account.sessions.update_all(["traffic_source = ?", self.source_type], ['referrer_host = ?', self.host])
  end

end
