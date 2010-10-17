module Analytics
  module Model
    module Utils
      def self.included(base)
        base.class_eval do
          named_scope :having,    lambda {|having| {:having => having} }
          named_scope :limit,     lambda {|limit| {:limit => limit} }
          named_scope :order,     lambda {|order| {:order => order} }       
          named_scope :filter,    lambda {|conditions| {:conditions => conditions} }
          named_scope :property,  lambda {|property|
            if property.is_a?(Property)
              { :conditions => ["property_id = ?", property.id] } 
            else
              { :conditions => ["property_id = ?", Property.find_by_name(property).try(:id)] } 
            end
          }
        end
      end
    end
  end
end