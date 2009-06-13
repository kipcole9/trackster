class History < ActiveRecord::Base
  belongs_to    :historical, :polymorphic => true
  belongs_to    :actionable, :polymorphic => true
  belongs_to    :created_by, :class_name => "User", :foreign_key => :created_by
  serialize     :updates
  default_scope :order => "created_at DESC"
  
  def self.record(record, transaction)
    return nil if transaction == :update && record.changes.blank?
    @refers_to = nil
    @history = History.new
    @history.historical = record
    @history.created_by = created_by(record, transaction)
    @history.transaction = transaction.to_s
    @history.actionable = refers_to(record)
    if transaction == :delete
      @history.updates = delete_metadata(record, record.attributes)
    else      
      @history.updates = delete_metadata(record, record.changes)
    end
    @history.save
  end

private
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
end
