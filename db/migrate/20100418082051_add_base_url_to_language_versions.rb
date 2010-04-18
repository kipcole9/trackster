class AddBaseUrlToLanguageVersions < ActiveRecord::Migration
  def self.up
    add_column :language_versions, :base_url, :string
    remove_column :redirects, :property_id
  end

  def self.down
    remove_column :language_versions, :base_url
  end
end
