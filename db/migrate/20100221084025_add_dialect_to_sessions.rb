class AddDialectToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :dialect, :string, :limit => 5
  end

  def self.down
    remove_column :sessions, :dialect
  end
end
