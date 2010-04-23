class AddAccountIdIndexToSessions < ActiveRecord::Migration
  def self.up
    add_index :sessions, :account_id
  end

  def self.down
  end
end
