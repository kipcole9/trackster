class AddMoreColumnsToImport < ActiveRecord::Migration
  def self.up
    add_column :imports, :created, :integer
    add_column :imports, :updated, :integer
  end

  def self.down
    remove_column :imports, :updated
    remove_column :imports, :created
  end
end
