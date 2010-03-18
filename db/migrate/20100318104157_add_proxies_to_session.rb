class AddProxiesToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :forwarded_for, :string, :limit => 100
  end

  def self.down
    remove_column :sessions, :forwarded_for
  end
end
