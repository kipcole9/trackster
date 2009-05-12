class ReviseTracksView < ActiveRecord::Migration
  def self.up
    #Create Tracks as a join of Session and Event - remove duplicate columns that add no 
    #value in retrieval data
    #execute "drop view tracks"
    column = []
    Session.columns.each do |a| 
      unless ['created_at', 'updated_at', 'id'].include?(a.name)
        column << a.name
      end
    end

    Event.columns.each do |a|
      unless ['created_at', 'updated_at', 'track_id'].include?(a.name)
        if a.name =='id'
          column << 'events.id as track_id'
        else
          column << a.name
        end
      end
    end

    execute "create view tracks as select #{column.join(', ')} from sessions join events on sessions.id = events.session_id"
  end

  def self.down
    execute "drop view tracks"
  end
end
