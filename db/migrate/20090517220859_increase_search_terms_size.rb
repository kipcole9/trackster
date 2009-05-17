class IncreaseSearchTermsSize < ActiveRecord::Migration
  def self.up
    change_column :search_engines, :query_param, :string, :limit => 50
  end

  def self.down
    change_column :search_engines, :query_param, :string, :limit => 10    
  end
end
