module Analytics
  class Visitor
    attr_accessor :visitor, :visit, :previous_visit_at
  
    def initialize(visitor_cookie)
      return if visitor_cookie.blank?
      @visitor, @visit, @previous_visit_at = visitor_cookie.split('.') 
    end
  end
end