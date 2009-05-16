class AddInternalSearchParameterToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :search_parameter, :string
  end

  def self.down
    remove_column :properties, :search_parameter
  end
end
