class AddIpFilterToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :ip_filter, :string
    add_column :accounts, :ip_filter_sql, :string
    add_column :sessions, :ip_integer, :integer
    Session.all.each{|s| s.save}
    add_index  :sessions, :ip_integer
  end

  def self.down
    remove_column :accounts, :ip_filter_sql
    remove_column :accounts, :ip_filter
    remove_column :sessions, :ip_integer
  end
end
