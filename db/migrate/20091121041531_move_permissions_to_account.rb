class MovePermissionsToAccount < ActiveRecord::Migration
  def self.up
    # Create account_users
    create_table :account_users, :force => true do |t|
      t.integer     :account_id
      t.integer     :user_id
      t.string      :role_id
    end
    add_index :account_users, [:account_id, :user_id], :unique => true
    
    # For each current user on an account create an entry in account_users
    # for that account.  Describe as admin role for now
    #Account.all.each do |a|
    #  a.properties.each do |p|
    #    p.users.each do |u|
    #      unless a.account_users.find_by_user_id(u.id)
    #        u.account_users << AccountUser.new(:user => u, :account => a, :role_id => 1)
    #      end
    #    end
    #  end
    #end
    
  end

  def self.down
    drop_table :account_users
  end
end
