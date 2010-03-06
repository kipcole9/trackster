module Analytics
  module Time
    def client
      Session.all.each do |s|
        if s.timezone
          s.started_at = s.started_at + s.timezone.minutes
          s.ended_at = s.ended_at + s.timezone.minutes
          s.events.all.each do |e|
            e.tracked_at += s.timezone.minutes
            e.save!
          end
          s.save_time_metrics({})
          s.save!
        end
      end
    end
  end
end