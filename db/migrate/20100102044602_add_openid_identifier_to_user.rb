class AddOpenidIdentifierToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :openid_identifier, :string
    remove_column :users, :activation_code
  end

  def self.down
    remove_column :users, :openid_identifier
    add_column :users, :activation_code, :string
  end
end
