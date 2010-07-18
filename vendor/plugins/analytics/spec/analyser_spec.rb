require 'rubygems'
require 'active_support'
plugin_lib = "#{File.dirname(__FILE__)}/../lib"
require "#{plugin_lib}/analytics/params"
require "#{plugin_lib}/log_tailer"
require "#{plugin_lib}/analytics/track_event"
require "#{plugin_lib}/analytics/log_parser"
require "#{plugin_lib}/analytics/referrer"
require "#{plugin_lib}/analytics/system"
require "#{plugin_lib}/analytics/url"
require "#{plugin_lib}/analytics/visitor"
require "#{plugin_lib}/analytics/session"
require "#{plugin_lib}/analytics/location"
require "#{plugin_lib}/analytics/email_client"

describe Analytics do
  before(:each) do
    @parser = Analytics::LogParser.new
  end
  
  it "should parse the log entry" do
    log_record = <<-EOL
      68.214.53.66 - - [16/Jun/2010:21:05:14 +0000] "GET /_tks.gif?utac=tks-0befd3-1&utses=1276736719.1&utvis=5CI8052V8EhlU80.1.1276736719&utmdt=No%20Expectations%20Image%20-%20Cloud%20Trees%2C%20Sapa%2C%20Vietnam&utmsr=1680x1050&utmsc=24&utmul=en-US&utmcs=utf-8&utmfl=10.0&utmn=8414617988&utref=http%3A%2F%2Fwww.google.com%2Fimgres%3Fimgurl%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam-full.jpg%26imgrefurl%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam%26usg%3D__mXm9FPLHBZzkxDqrqY_lFoiSpo0%3D%26h%3D501%26w%3D800%26sz%3D84%26hl%3Den%26start%3D59%26sig2%3DN4sAZup2CSUeAUI2ZgPsdw%26um%3D1%26itbs%3D1%26tbnid%3Dc9NZw8VB-f8XrM%3A%26tbnh%3D90%26tbnw%3D143%26prev%3D%2Fimages%253Fq%253Dsapa%252Bvietnam%2526start%253D42%2526um%253D1%2526hl%253Den%2526client%253Dfirefox-a%2526sa%253DN%2526rls%253Dorg.mozilla%3Aen-US%3Aofficial%2526ndsp%253D21%2526tbs%253Disch%3A1%26ei%3DYTwZTMT7HsH6lwf5mrmrCw&uttz=-240&utmp=http%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam&uver=1.1 HTTP/1.1" 200 43 "http://www.noexpectations.com.au/images/cloud-trees-sapa-vietnam" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" "-"
    EOL
    
    @parser.parse log_record do |r|
      r.ip_address.should == '68.214.53.66'
    end
  end

end