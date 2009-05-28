class AddUserAgentToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :user_agent, :string
  end

  def self.down
    remove_column :sessions, :user_agent
  end
end
