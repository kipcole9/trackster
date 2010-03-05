class AddIndexPageToEvents < ActiveRecord::Migration
  def self.up
    add_column :properties, :index_page, :string, :limit => 50, :default => "index.*"
  end

  def self.down
    remove_column :properties, :index_page
  end
end
