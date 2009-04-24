module FixLog
  def fix_views
    rows = Track.find(:all, :conditions => "visitor IS NOT NULL and session IS NOT NULL AND visit IS NULL AND view IS NULL", 
                :order => "visitor, session, tracked_at")
    @visitor = ''
    @session = ''
    @visit = @view = 1

    rows.each do |r|
      if r.visitor != @visitor
        puts "New visitor: #{r.visitor}"
        @visit = 1
        @visitor = r.visitor
      else
        if r.session != @session
          @visit += 1
        end
      end
      
      if r.session != @session
        puts "New session: #{r.session}"
        @view = 1
        @session = r.session
      end
    
      r.visit = @visit
      r.view = @view
      puts "Saving visit #{@visit} and view #{@view}"
      r.save!
      
      @view += 1
      
    end
    "Finished processing #{rows.size} rows."
  end
  
  def fix_durations
    sessions = Track.find(:all, :select => "distinct visitor, session", :conditions => "session IS NOT NULL")
    sessions.each do |row|
      views = Track.find(:all, :conditions => ["visitor = ? AND session = ?", row.visitor, row.session], :order => "view DESC")
      if views
        if views.first && views.first.duration.nil?
          views.first.duration = views.first.tracked_at.to_i - views.last.tracked_at.to_i
          views.first.save!
          views[1..-1].each do |v|
            if !v.duration.nil?
              v.duration = nil
              v.save!
            end
          end
        end
      end
    end
  end
        
      
end