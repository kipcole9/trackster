class RemoveChartBackgroundColumn < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :chart_background_colour
  end

  def self.down
    add_column :accounts, :chart_background_colour, :string
  end
end
