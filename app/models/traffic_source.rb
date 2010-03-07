class TrafficSource < ActiveRecord::Base
  belongs_to              :account 
  validates_associated    :account
  validates_presence_of   :account_id
  validates_uniqueness_of :host, :scope => :account_id
  #after_save              :update_sessions
  
  def self.import_search_engines
    account = Account.admin
    SearchEngine.all.each do |engine|
      ts = account.traffic_sources.find_or_create_by_host(engine.host)
      if engine.host =~ /\Amaps\./i 
        ts.source_type = 'map search'
      elsif engine.host =~ /\Aimages\./ 
        ts.source_type = 'image search'        
      elsif engine.host =~ /\Ablogsearch\./ 
        ts.source_type = 'blog search'        
      else
        ts.source_type = 'organic search'
      end
      ts.save
    end
  end
  
  def self.find_from_referrer(referrer_host, account)
    host = referrer_host.sub(/\Awww\./,'')
    account.traffic_sources.find_by_host(host) || Account.admin.traffic_sources.find_by_host(host)
  end
  
private  
  def update_sessions
    self.account.sessions.update_all(["traffic_source = ?", self.source_type], ['referrer_host = ?', self.host])
  end
end
