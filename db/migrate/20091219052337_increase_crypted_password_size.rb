class IncreaseCryptedPasswordSize < ActiveRecord::Migration
  def self.up
    change_column :users, :crypted_password, :string
    change_column :users, :password_salt, :string
  end

  def self.down
  end
end
