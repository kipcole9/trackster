class AddIndexToRedirects < ActiveRecord::Migration
  def self.up
    add_index :redirects, :redirect_url
    add_index :redirects, :account_id
    add_index :redirects, :name
  end

  def self.down
  end
end
