module Analytics
  class Session
    attr_accessor :session, :view
    
    def initialize(session_cookie)
      return if session_cookie.blank?
      @session, @view = session_cookie.split('.')
    end
  end
end