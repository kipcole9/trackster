class AddAgentToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :agent_id, :integer
  end

  def self.down
    remove_column :accounts, :agent_id
  end
end
