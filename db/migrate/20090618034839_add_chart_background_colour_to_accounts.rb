class AddChartBackgroundColourToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :chart_background_colour, :string, :limit => 7
  end

  def self.down
    remove_column :accounts, :chart_background_colour
  end
end
