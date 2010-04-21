class AddAccountIdKeysToCampaignsAndContent < ActiveRecord::Migration
  def self.up
    add_index :contents, :account_id
  end

  def self.down
  end
end
