class AddReferrerCategoryToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :referrer_category, :string, :limit => 50
  end

  def self.down
    remove_column :sessions, :referrer_category
  end
end
