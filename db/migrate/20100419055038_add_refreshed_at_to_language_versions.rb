class AddRefreshedAtToLanguageVersions < ActiveRecord::Migration
  def self.up
    add_column :language_versions, :refreshed_at, :datetime
  end

  def self.down
    remove_column :language_versions, :refreshed_at
  end
end
