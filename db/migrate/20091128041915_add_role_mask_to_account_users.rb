class AddRoleMaskToAccountUsers < ActiveRecord::Migration
  def self.up
    remove_column :account_users, :role_id
    add_column :account_users, :role_mask, :integer
    
    drop_table :roles
    drop_table :roles_users
    drop_table :property_users
  end

  def self.down
  end
end
