module Analytics
  class EmailClient
    attr_reader :user_agent, :referrer
    
    def initialize(user_agent, referrer)
      @user_agent = user_agent
      @referrer = referrer
    end
    
    def name
      original_browser = self.user_agent
      client = nil
      if self.user_agent =~ /MSOffice 12/i
        client = "Outlook 2007"
      elsif self.user_agent =~ /Microsoft Office\/14.0/
        client = "Outlook 2010"
      elsif self.referrer && self.referrer.gmail? 
        client = "GMail"
      elsif self.referrer && self.referrer.hotmail?
        client = 'Hotmail'
      elsif self.referrer && self.referrer.yahoo_mail?
        client = 'Yahoo Mail'
      elsif self.referrer && self.referrer.live_mail?
        client = 'Microsoft Live'
      elsif self.user_agent =~ /iPod|iPhone/
        client = 'iPhone Mail'
      elsif self.user_agent =~ /AppleWebKit/
        client = 'Apple Mail'
      elsif self.user_agent =~ /Thunderbird/
        client = "Thunderbird"
      elsif self.user_agent =~ /Lotus-Notes/
        client = 'Lotus Notes' 
      elsif self.user_agent =~ /Eudora/
        client = 'Eudora'
      elsif self.user_agent =~ /MAC OS X.*Tasman/
        client = "Entourage"          
      elsif self.user_agent =~ /MSIE/
        client = 'Outlook 2003'
      end
      client
    end
  end
end