class History < ActiveRecord::Base
  belongs_to    :account
  belongs_to    :historical, :polymorphic => true
  belongs_to    :actionable, :polymorphic => true
  belongs_to    :created_by, :class_name => "User", :foreign_key => :created_by
  serialize     :updates
  default_scope :order => "id DESC"
  
  CONTACT_TABLES = ["Contact", "Phone", "Website", "Address", "Email"]
  
  named_scope :for_contacts, :conditions => {:actionable_type => CONTACT_TABLES}, :order => "id DESC"
  named_scope :back_to, lambda {|time|
    time ? { :conditions => ["created_at >= ?", time] } : { }
  }
  
  def self.record(record, transaction)
    return nil if transaction == :update && record.changes.blank?
    @refers_to = nil
    @history = History.new(:historical => record, :created_by => User.current_user, 
                           :transaction => transaction.to_s, :actionable => refers_to(record))
    @history.updates = (transaction == :delete) ? record.attributes : record.changes
    @history.account = Account.current_account # @history.actionable.try(:account)
    @history.created_at = Time.zone.now  # in case ActiveRecord::Base.record_timestamps is turned off
    @history.save!
  end
  

private
  # No longer delete metadata since we want the rollback
  # to be as close to possible as the actual conditions at
  # the time before the CRUD occurred. Hence we don't currently invoke this
  def self.delete_metadata(record, attribs)
    attribs.delete_if{|k, v| k.to_s == record.class.primary_key || k.to_s =~ /_(at|on|id|by|type)\Z/ }
  end
  
  def self.refers_to(record)
    reflections = belongs_to_reflections(record)
    @refers_to ||= if record.respond_to?(:refers_to)
      record.refers_to
    elsif reflections.size == 1
      record.send first_reflection(reflections)
    else
      record
    end
  end
  
  def self.created_by(record, transaction)
    if record.respond_to?(:created_by) && transaction == :create
      record.created_by
    elsif record.respond_to?(:updated_by) && transaction == :update
      record.updated_by
    elsif referer = refers_to(record)
      referer.send(:updated_by) if referer.respond_to?(:updated_by)
    else
      nil
    end
  end
    
  def self.belongs_to_reflections(record)
    record.class.reflections.delete_if {|k, v| k.to_s =~ /_(by|at)\Z/ || v.macro != :belongs_to}
  end
  
  def self.first_reflection(reflections)
    reflections.each {|k, v| return k}
  end
  
private
  def ensure_updates_is_not_nil
    self.updates = {} if self.updates.blank?
  end
  
end
