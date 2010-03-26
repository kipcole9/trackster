class LengthenLabelColumn < ActiveRecord::Migration
  def self.up
    change_column :events, :label, :string, :limit => 255
  end

  def self.down
    change_column :events, :label, :string, :limit => 100
  end
end
