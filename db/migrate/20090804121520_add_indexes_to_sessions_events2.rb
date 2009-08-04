class AddIndexesToSessionsEvents2 < ActiveRecord::Migration
  def self.up
    # add_index(:accounts, [:branch_id, :party_id], :unique => true)
    add_index :sessions, :property_id
    add_index :sessions, :campaign_id
    
    add_index :events, :session_id    
  end

  def self.down
  end
end
