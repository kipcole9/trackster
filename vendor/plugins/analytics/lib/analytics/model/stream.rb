module Analytics
  module Model
    module Stream
      def self.included(base)
        base.class_eval do         
          named_scope :stream,
            :select => "sessions.*, events.*",
            :joins => :events
        end
      end
    end
  end
end