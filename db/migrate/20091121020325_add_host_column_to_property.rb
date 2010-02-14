class AddHostColumnToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :host, :string, :limit => 70
    add_index :properties, :host
    
    # Update each property to trigger setting of host column
    #Property.all.each {|p| p.url_will_change!; p.save!}
    
  end

  def self.down
    remove_column :properties, :host
  end
end
