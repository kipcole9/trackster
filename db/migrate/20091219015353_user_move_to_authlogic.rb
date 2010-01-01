class UserMoveToAuthlogic < ActiveRecord::Migration
  def self.up
    rename_column :users, :salt, :password_salt
    
    add_column :users, :persistence_token, :string,     :null => false
    add_column :users, :single_access_token, :string,   :null => false
    add_column :users, :perishable_token, :string,      :null => false
    
    add_column :users, :login_count, :integer,          :null => false, :default => 0
    add_column :users, :failed_login_count, :integer,   :null => false, :default => 0
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
    
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end

  def self.down
  end
end
