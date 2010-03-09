class AddTagsToAccountUser < ActiveRecord::Migration
  def self.up
    add_column :account_users, :tags, :string
  end

  def self.down
    remove_column :account_users, :tags
  end
end
