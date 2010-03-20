class AddIndicesSomeTables < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :unique => true
    add_index :properties, [:account_id, :name], :unique => true
    
  end

  def self.down
  end
end
