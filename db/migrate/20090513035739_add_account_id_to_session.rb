class AddAccountIdToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :account_id, :integer
  end

  def self.down
    remove_column :sessions, :account_id
  end
end
