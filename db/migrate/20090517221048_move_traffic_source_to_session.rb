class MoveTrafficSourceToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :traffic_source, :string, :limit => 50
    execute 'update sessions join events on sessions.id = events.session_id set sessions.traffic_source = events.traffic_source'    
    remove_column :events, :traffic_source

    execute "drop view tracks"    
    column = []
    Session.columns.each do |a| 
      unless ['created_at', 'updated_at', 'id'].include?(a.name)
        column << a.name
      end
    end

    Event.columns.each do |a|
      unless ['created_at', 'updated_at', 'track_id'].include?(a.name)
        if a.name =='id'
          column << 'events.id as id'
        else
          column << a.name
        end
      end
    end

    execute "create view tracks as select #{column.join(', ')} from sessions join events on sessions.id = events.session_id"
  end

  def self.down

  end
end
