require 'test_helper'

LOG_RECORD = <<-EOL
68.214.53.66 - - [16/Jun/2010:21:05:14 +0000] "GET /_tks.gif?utac=tks-0befd3-1&utses=1276736719.1&utvis=5CI8052V8EhlU80.1.1276736719&utmdt=No%20Expectations%20Image%20-%20Cloud%20Trees%2C%20Sapa%2C%20Vietnam&utmsr=1680x1050&utmsc=24&utmul=en-US&utmcs=utf-8&utmfl=10.0&utmn=8414617988&utref=http%3A%2F%2Fwww.google.com%2Fimgres%3Fimgurl%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam-full.jpg%26imgrefurl%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam%26usg%3D__mXm9FPLHBZzkxDqrqY_lFoiSpo0%3D%26h%3D501%26w%3D800%26sz%3D84%26hl%3Den%26start%3D59%26sig2%3DN4sAZup2CSUeAUI2ZgPsdw%26um%3D1%26itbs%3D1%26tbnid%3Dc9NZw8VB-f8XrM%3A%26tbnh%3D90%26tbnw%3D143%26prev%3D%2Fimages%253Fq%253Dsapa%252Bvietnam%2526start%253D42%2526um%253D1%2526hl%253Den%2526client%253Dfirefox-a%2526sa%253DN%2526rls%253Dorg.mozilla%3Aen-US%3Aofficial%2526ndsp%253D21%2526tbs%253Disch%3A1%26ei%3DYTwZTMT7HsH6lwf5mrmrCw&uttz=-240&utmp=http%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fcloud-trees-sapa-vietnam&uver=1.1 HTTP/1.1" 200 43 "http://www.noexpectations.com.au/images/cloud-trees-sapa-vietnam" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" "-"
EOL


class AnalyticsTest < Test::Unit::TestCase
  def test_parse_good_log_record
    Analytics::LogParser.new.parse(LOG_RECORD) do |r|
      assert r[:ip_address] == '68.214.53.66'
      assert r[:time]       == '16/Jun/2010:21:05:14 +0000'
      assert r[:user_agent] == "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"
      assert r[:forwarded_for] == "-"
    end
  end
  
  def test_event_decoding
    Analytics::LogParser.new.parse(LOG_RECORD) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert track.ip_address     == '68.214.53.66'
        assert track.user_agent     == "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"
        assert track.browser        == 'Firefox'
        assert track.dialect        == 'en-US'
        assert track.language       == 'en'
        assert track.account_code   == 'tks-0befd3-1'
        assert track.session        == '1276736719'
        assert track.view           == '1'
        assert track.visitor        == '5CI8052V8EhlU80'
        assert track.visit          == '1'
        assert track.screen_size    == '1680x1050'
        assert track.color_depth    == '24'
        assert track.flash_version  == "10.0"
        assert track.timezone       == "-240"
        assert !track.crawler_agent?
        assert !track.agent_banned?
      end
    end
  end
    
  def test_referrer
    Analytics::LogParser.new.parse(LOG_RECORD) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.page_title, "No Expectations Image - Cloud Trees, Sapa, Vietnam"
        assert_equal track.traffic_source,  'search'
      end
    end
  end
  
  def test_location
    Analytics::LogParser.new.parse(LOG_RECORD) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.country, 'US'
        assert_nil track.region
        assert_nil track.locality
      end
    end
  end

LOG_RECORD2 = <<-EOL
61.8.124.86 - - [17/Jun/2010:00:09:28 +0000] "GET /_tks.gif?utac=7e4b5d&utses=1276697372.2&utvis=BGH4vtiLXHTLGoW.1.1268329680&utmdt=make%20it%20happen%20-%20about%20us%20-%20our%20company&utmsr=1680x1050&utmsc=32&utmul=en-au&utmcs=utf-8&utmfl=10.0&utmn=6916341942&utref=http%3A%2F%2Fwww.mih.com.au%2F&uttz=600&utmp=http%3A%2F%2Fwww.mih.com.au%2Four_company.html&uver=1.1 HTTP/1.1" 200 43 "http://www.mih.com.au/our_company.html" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)" "-"
EOL
  def test_check_locality
    Analytics::LogParser.new.parse(LOG_RECORD2) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.ip_address, '61.8.124.86'
        assert_equal track.country,    'AU'
      end
    end
  end
  
LOG_RECORD3 = <<-EOL
60.229.176.228 - - [18/Jul/2010:01:09:22 +0000] "GET /_tks.gif?utac=ae0031&utses=1279379274.3&utvis=G7Uz0Gp1UgYKXXq.1164.1279379274.1279376373&utmsr=1280x800&utmsc=24&utmul=en-US&utmcs=utf-8&utmfl=10.1&utmn=1374499282&uttz=600&utmp=http%3A%2F%2Fwww.sapapj.asia%2FmihFFM%2Fbin%2Fportal.html%23marketing-university&utlab=FFM%20Marketing_University&uver=1.1 HTTP/1.1" 200 43 "http://www.xroads.com.au/ffmtest/mihffm_v204.html" "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6 ( .NET CLR 3.5.30729)" "-"
EOL
  def test_user_agent_and_session_params
    Analytics::LogParser.new.parse(LOG_RECORD3) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert track.ip_address == '60.229.176.228'
        assert track.user_agent == "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6 ( .NET CLR 3.5.30729)"
        assert track.browser    == "Firefox"
        assert track.os_name    == "Windows"
        assert track.os_version == 'XP'
      end
    end
  end 
  
LOG_RECORD_REDIR = <<-EOL
217.88.122.127 - - [14/Jul/2010:06:15:36 +0000] "GET /r/f8790e HTTP/1.0" 302 0 "http://www.google.de" "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.9.0.17) Gecko/2009122116 Firefox/3.0.17 GTB6 (.NET CLR 3.5.30729)" "-"
EOL
  def test_redirect
    Analytics::LogParser.new.parse(LOG_RECORD_REDIR) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.ip_address,    '217.88.122.127'
        assert_equal track.redirect_code, 'f8790e'
        assert       track.redirect?
        assert_equal track.url,           "http://www.sap.com/company/legal/impressum.epx"
        assert_equal track.category,      'page'
        assert_equal track.action,        'view'
        assert_equal track.country,       'DE'
        assert_equal track.traffic_source, 'direct'
      end
    end
  end      
  
LOG_RECORD_CAMP = <<-EOL
61.8.124.86 - - [01/Jul/2010:00:42:54 +0000] "GET /_tks.gif?utac=f0099b&utm_campaign=f87d0f&utm_medium=email&utid=999901&utcat=email&utact=open HTTP/1.1" 200 43 "-" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)" "-"
EOL
  def test_campaign_opening
    Analytics::LogParser.new.parse(LOG_RECORD_CAMP) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.ip_address,    '61.8.124.86'
        assert_equal track.browser,       'IE'
        assert_equal track.category,      'email'
        assert_equal track[:category],    'email'
        assert_equal track.action,        'open'
        assert_equal track.contact_code,  '999901'
        assert_equal track.campaign_medium, 'email'
        assert_equal track.campaign_name, 'f87d0f'
        assert_equal track.account_code,  'f0099b'
      end
    end    
  end
  
LOG_RECORD_ENTITY = <<-EOL
203.41.143.148 - - [01/Jul/2010:01:50:58 +0000] "GET /_tks.gif?utac=f0099b&amp;utm_campaign=f87d0f&amp;utm_medium=email&amp;utid=34&amp;utcat=email&amp;utact=open HTTP/1.0" 200 43 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)" "-"
EOL
  def test_params_entity_encoded
    Analytics::LogParser.new.parse(LOG_RECORD_ENTITY) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.ip_address,    '203.41.143.148'
        assert_equal track.account_code,  'f0099b'
        assert_equal track.campaign_name, 'f87d0f'
        assert_equal track.campaign_medium, 'email'
        assert_equal track.category,      'email'
        assert_equal track[:category],    'email'
        assert_equal track.action,        'open'
      end
    end    
  end

LOG_TEST_5 = <<-EOL
165.228.184.148 - - [06/Sep/2010:01:17:41 +0000] "GET /_tks.gif?utac=7e4b5d&utses=1283699861.1&utvis=Lqc7XDOpp3yxcHU.1.1283699861&utmdt=make%20it%20happen%20-%20Marketing%20Agency%2C%20Sydney%20-%20Channel%2C%20Lead%20Generation%20%26%20Creative%20Services&utmsr=1024x768&utmsc=32&utmul=en-au&utmcs=utf-8&utmfl=10.1&utmn=4705789480&utref=http%3A%2F%2Fwww.yellowpages.com.au%2Fsearch%2Flistings%3Fclue%3Dmarketing%2Bservices%2B%2526%2Bconsultants%26locationClue%3Dnsw%26x%3D35%26y%3D23&uttz=600&utmp=http%3A%2F%2Fwww.mih.com.au&uver=1.2 HTTP/1.1" 200 43 "" "Mozilla/4.0 (compatible; MSIE 999.1; Unknown)" "-"
EOL
  def test_broken_record_1
    Analytics::LogParser.new.parse(LOG_TEST_5) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_nil track
      end
    end    
  end
  
LOG_TEST_6 = <<-EOL
165.228.184.148 - - [06/Sep/2010:03:11:48 +0000] "GET /_tks.gif?utac=7e4b5d&utses=1283706709.1&utvis=BJINakvZZOXvYJl.1.1283706709&utmdt=make%20it%20happen%20-%20Marketing%20Agency%2C%20Sydney%20-%20Channel%2C%20Lead%20Generation%20%26%20Creative%20Services&utmsr=1280x1024&utmsc=32&utmul=en-au&utmcs=utf-8&utmfl=10.1&utmn=8664513776&uttz=600&utmp=http%3A%2F%2Fwww.mih.com.au&uver=1.2 HTTP/1.1" 200 43 "" "Mozilla/4.0 (compatible; MSIE 999.1; Unknown)" "-"
EOL
  def test_broken_record_2
    Analytics::LogParser.new.parse(LOG_TEST_6) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_nil track
      end
    end
  end

LOG_TEST_7 = <<-EOL
165.228.184.148 - - [06/Sep/2010:03:12:32 +0000] "GET /_tks.gif?utac=7e4b5d&utses=1283706709.2&utvis=BJINakvZZOXvYJl.1.1283706709&utmdt=make%20it%20happen%20-%20about%20us%20-%20our%20people&utmsr=1280x1024&utmsc=32&utmul=en-au&utmcs=utf-8&utmfl=10.1&utmn=4999899522&utref=http%3A%2F%2Fwww.mih.com.au%2F&uttz=600&utmp=http%3A%2F%2Fwww.mih.com.au%2Four_people.html&uver=1.2 HTTP/1.1" 200 43 "" "Mozilla/4.0 (compatible; MSIE 999.1; Unknown)" "-"
EOL
  def test_broken_record_3
    Analytics::LogParser.new.parse(LOG_TEST_7) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_nil track
      end
    end
  end


LOG_TEST_8 = <<-EOL
71.193.150.248 - - [07/Oct/2010:06:33:47 +0000] "GET /_tks.gif?utac=tks-0befd3-1&utses=1286458427.1&utvis=A1kDbfv7F25pcND.1.1286458427&utmdt=No%20Expectations%20-%20Unrecognized%3F%20Application&utmsr=1280x800&utmsc=24&utmul=en-us&utmcs=utf-8&utmfl=10.0&utmn=6186802476&uttz=-420&utmp=http%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fbar-rouge-shangai-from-a-different-angle-full.jpg%26imgrefurl%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fgalleries%2Fshanghai-shapshots-july-2009%26usg%3D__OaQ02zzhg1H6KmiLtrw_sBXOJho%3D%26h%3D578%26w%3D800%26sz%3D160%26hl%3Den%26start%3D229%26zoom%3D1%26tbnid%3DYglqOz-L_qXIHM%3A%26tbnh%3D158%26tbnw%3D252%26prev%3D%2Fimages%253Fq%253Dbar%252Brouge%252Bshanghai%2526um%253D1%2526hl%253Den%2526client%253Dsafari%2526sa%253DX%2526rls%253Den%2526biw%253D1276%2526bih%253D673%2526tbs%253Disch%3A10%252C8232%26um%3D1%26itbs%3D1%26iact%3Dhc%26vpx%3D981%26vpy%3D258%26dur%3D405%26hovh%3D182%26hovw%3D252%26tx%3D57%26ty%3D103%26ei%3DsmmtTKXFKIWXnAeKkqmjBg%26oei%3DiWmtTMbpAuOfnweTy6nNBQ%26esq%3D11%26page%3D16%26ndsp%3D16%26ved%3D1t%3A429%2Cr%3A4%2Cs%3A229%26biw%3D1276%26bih%3D673&uver=1.2 HTTP/1.1" 200 43 "http://www.noexpectations.com.au/images/bar-rouge-shangai-from-a-different-angle-full.jpg&imgrefurl=http://www.noexpectations.com.au/galleries/shanghai-shapshots-july-2009&usg=__OaQ02zzhg1H6KmiLtrw_sBXOJho=&h=578&w=800&sz=160&hl=en&start=229&zoom=1&tbnid=YglqOz-L_qXIHM:&tbnh=158&tbnw=252&prev=/images%3Fq%3Dbar%2Brouge%2Bshanghai%26um%3D1%26hl%3Den%26client%3Dsafari%26sa%3DX%26rls%3Den%26biw%3D1276%26bih%3D673%26tbs%3Disch:10%2C8232&um=1&itbs=1&iact=hc&vpx=981&vpy=258&dur=405&hovh=182&hovw=252&tx=57&ty=103&ei=smmtTKXFKIWXnAeKkqmjBg&oei=iWmtTMbpAuOfnweTy6nNBQ&esq=11&page=16&ndsp=16&ved=1t:429,r:4,s:229&biw=1276&bih=673" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10" "-"
EOL
  def test_search_terms_1
    Analytics::LogParser.new.parse(LOG_TEST_8) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.search_terms, "test"
      end
    end
  end
  
LOG_TEST_9 = <<-EOL
87.78.94.181 - - [15/Aug/2010:12:41:38 +0000] "GET /_tks.gif?utac=tks-0befd3-1&utses=1281868900.1&utvis=QWG2nLLYcxsgivn.1.1281868900&utmdt=No%20Expectations%20Image%20-%20Old%20Peat%27s%20Ferry%20Road%20in%20Muogamarra%20Nature%20Reserve&utmsr=1680x1050&utmsc=24&utmul=de&utmcs=UTF-8&utmfl=10.0&utmn=7479316647&uttz=120&utmp=http%3A%2F%2Ftranslate.googleusercontent.com%2Ftranslate_c%3Fhl%3Dde%26sl%3Den%26u%3Dhttp%3A%2F%2Fwww.noexpectations.com.au%2Fimages%2Fold-peats-ferry-road-in-muogamarra-nature-reserve%26prev%3D%2Fsearch%253Fq%253Dold%252Bpeat%252Broad%2526hl%253Dde%26rurl%3Dtranslate.google.de%26usg%3DALkJrhi7EtPyGkD-_602XtObBcbpZTiYzQ&uver=1.2 HTTP/1.1" 200 43 "http://translate.googleusercontent.com/translate_c?hl=de&sl=en&u=http://www.noexpectations.com.au/images/old-peats-ferry-road-in-muogamarra-nature-reserve&prev=/search%3Fq%3Dold%2Bpeat%2Broad%26hl%3Dde&rurl=translate.google.de&usg=ALkJrhi7EtPyGkD-_602XtObBcbpZTiYzQ" "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.4; de; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8" "-"
EOL
  def test_search_terms_2
    Analytics::LogParser.new.parse(LOG_TEST_9) do |record|
      Analytics::TrackEvent.analyse(record) do |track|
        assert_equal track.search_terms, "test"
      end
    end
  end
  
end

 

