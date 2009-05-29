require 'rubygems'
require File.dirname(__FILE__) + '/../lib/device_atlas'
require 'spec'
require 'active_support'

describe DeviceAtlas do
  
  before(:each) do
    @da = DeviceAtlas.new
    @tree = @da.getTreeFromFile("../20080604.json")
  end

  it "the api revision should be 2830" do
    @da.getApiRevision.should == 2830
  end
  
  it "the tree revision should be 2590" do
    @da.getTreeRevision(@tree).should == 2590
  end
  
  it "the json tree should have nodes '$', 't', 'pr', 'pn', 'v', 'p' " do
    nodes = ['$', 't', 'pr', 'pn', 'v', 'p']
    
    @tree.each_key do |node|
      nodes.include?(node).should be_true
    end
  end
  
  it "@tree['pr'] should be a hash lookup of properties with the type code prefix, the value is the property code" do
    @tree['pr'].has_key?('bisBrowser').should be_true
    @tree['pr']['bisBrowser'].should == 68
  end
  
  it "@tree['pn'] should be a hash lookup of properties without the type code prefix, the value is the property code" do
    @tree['pn'].has_key?('isBrowser').should be_true
    @tree['pn']['isBrowser'].should == 68
  end
  
  it "should be the jesus phone Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3" do
    user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
    property = @da.getProperty(@tree, user_agent, "displayWidth")
    property.should == 320
  end
  
  it "should return 176 as the display width for a SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    property = @da.getProperty(@tree, user_agent, "displayWidth")
    property.should == 176
  end
  
  it "should raise IncorrectPropertyTypeException getting displayWidth as a boolean" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    lambda { 
      @da.getPropertyAsBoolean(@tree, user_agent, "displayWidth")
    }.should raise_error(DeviceAtlas::IncorrectPropertyTypeException, "displayWidth is not of type boolean")
  end
  
  it "should raise IncorrectPropertyTypeException getting displayWidth as a date" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    lambda { 
      @da.getPropertyAsDate(@tree, user_agent, "displayWidth")
    }.should raise_error(DeviceAtlas::IncorrectPropertyTypeException, "displayWidth is not of type date")
  end
  
  it "should raise IncorrectPropertyTypeException getting displayWidth as a string" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    lambda { 
      @da.getPropertyAsString(@tree, user_agent, "displayWidth")
    }.should raise_error(DeviceAtlas::IncorrectPropertyTypeException, "displayWidth is not of type string")
  end
  
  it "should raise IncorrectPropertyTypeException trying to get a non existing property (bananas) as a String" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    lambda { 
      @da.getPropertyAsString(@tree, user_agent, "bananas")
    }.should raise_error(DeviceAtlas::IncorrectPropertyTypeException, "bananas is not of type string")
  end
  
  it "should raise UnknownPropertyException trying to find a non existing property (bananas) for a user agent" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    lambda { 
      @da.getProperty(@tree, user_agent, "bananas")
    }.should raise_error(DeviceAtlas::UnknownPropertyException, "The property bananas is not known in this tree.")
  end
  
  it "should get displayWidth as an Integer (Well, fixnum)" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    @da.getPropertyAsInteger(@tree, user_agent, "displayWidth").class.should == Fixnum
  end
  
  it "should get model as a String" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    @da.getPropertyAsString(@tree, user_agent, "model").class.should == String
  end
  
  it "should get mobileDevice as a Boolean" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    @da.getPropertyAsBoolean(@tree, user_agent, "mobileDevice").should === (true || false)
  end
  
  it "should return the list of properties for a SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    properties = @da.getProperties(@tree, user_agent)
    
    properties.diff({ "mobileDevice" => 1,  "vendor" => "Sony Ericsson", "image.Jpg" => 1, "image.Gif87" => 1,
      "uriSchemeTel" => 1, "markup.xhtmlMp10" => 1, "markup.xhtmlBasic10" => 1, "cookieSupport" => 1,
      "https" => 1, "memoryLimitMarkup" => 20000, "memoryLimitEmbeddedMedia" => 262144,  "memoryLimitDownload" => 262144,
      "midiMonophonic" => 1, "amr" => 1, "mpeg4" => 1, "3gpp" => 1, "h263Type0InVideo" => 1, "mpeg4InVideo" => 1,
      "amrInVideo" => 1, "aacInVideo" => 1, "drmOmaForwardLock" => 1, "drmOmaCombinedDelivery" => 1, "drmOmaSeparateDelivery" => 1,
      "csd" => 1, "gprs" => 1, "displayWidth" => 176, "displayHeight" => 220, "displayColorDepth" => 16, 
      "model" => "K700i", "image.Png" => 1, "mp3" => 0, "aac" => 0, "qcelp" => 0, "3gpp2" => 0, "wmv" => 0, "hscsd" => 0,
      "edge" => 0, "hsdpa" => 0, "umts"=> 0, "midiPolyphonic" => 0, "image.Gif89a" => 1, "usableDisplayWidth" => 170,
      "usableDisplayHeight" => 147, "midp" => "1.0", "cldc" => "1.0", "jsr30" => 1, "jsr139" => 0, "jsr37" => 1, "jsr118" => 0,
      "id" => 204912, "_matched" => "SonyEricssonK700i", "_unmatched" => "/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"}).should == {}
  end
  
  it "should return the list of properties TYPED for a SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
    user_agent = "SonyEricssonK700i/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    properties = @da.getPropertiesAsTyped(@tree, user_agent)
    
    properties.diff({ "mobileDevice" => true,  "vendor" => "Sony Ericsson", "image.Jpg" => true, "image.Gif87" => true,
      "uriSchemeTel" => true, "markup.xhtmlMp10" => true, "markup.xhtmlBasic10" => true, "cookieSupport" => true,
      "https" => true, "memoryLimitMarkup" => 20000, "memoryLimitEmbeddedMedia" => 262144,  "memoryLimitDownload" => 262144,
      "midiMonophonic" => true, "amr" => true, "mpeg4" => true, "3gpp" => true, "h263Type0InVideo" => true, "mpeg4InVideo" => true,
      "amrInVideo" => true, "aacInVideo" => true, "drmOmaForwardLock" => true, "drmOmaCombinedDelivery" => true, "drmOmaSeparateDelivery" => true,
      "csd" => true, "gprs" => true, "displayWidth" => 176, "displayHeight" => 220, "displayColorDepth" => 16, 
      "model" => "K700i", "image.Png" => true, "mp3" => false, "aac" => false, "qcelp" => false, "3gpp2" => false, "wmv" => false, "hscsd" => false,
      "edge" => false, "hsdpa" => false, "umts"=> false, "midiPolyphonic" => false, "image.Gif89a" => true, "usableDisplayWidth" => 170,
      "usableDisplayHeight" => 147, "midp" => "1.0", "cldc" => "1.0", "jsr30" => true, "jsr139" => false, "jsr37" => true, "jsr118" => false,
      "id" => 204912, "_matched" => "SonyEricssonK700i", "_unmatched" => "/R2AG SEMC-Browser/4.0.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"}).should == {}
  end
  
  it "should list all of the available properties and their types" do
    property_list = @da.listProperties(@tree)
    property_list.should == {"isBrowser"=>"boolean", "drmOmaForwardLock"=>"boolean", 
      "cookieSupport"=>"boolean", "model"=>"string", "csd"=>"boolean", 
      "h263Type0InVideo"=>"boolean", "memoryLimitDownload"=>"integer", 
      "h263Type3InVideo"=>"boolean", "aacLtpInVideo"=>"boolean", "umts"=>"boolean", 
      "isChecker"=>"boolean", "uriSchemeTel"=>"boolean", "awbInVideo"=>"boolean", 
      "3gpp"=>"boolean", "hsdpa"=>"boolean", "displayColorDepth"=>"integer", 
      "markup.xhtmlMp10"=>"boolean", "isDownloader"=>"boolean", 
      "osProprietary"=>"string", "https"=>"boolean", "mpeg4"=>"boolean", 
      "markup.xhtmlMp11"=>"boolean", "osVersion"=>"string", "image.Png"=>"boolean", 
      "wmv"=>"boolean", "isSpam"=>"boolean", "image.Gif87"=>"boolean", "3gpp2"=>"boolean", 
      "developerPlatform"=>"string", "markup.xhtmlMp12"=>"boolean", "stylesheetSupport"=>"string", 
      "aac"=>"boolean", "osRim"=>"boolean", "developerPlatformVersion"=>"string", 
      "jsr118"=>"boolean", "drmOmaCombinedDelivery"=>"boolean", "jsr139"=>"boolean", 
      "mp3"=>"boolean", "mobileDevice"=>"boolean", "edge"=>"boolean", "vendor"=>"string", 
      "image.Gif89a"=>"boolean", "usableDisplayWidth"=>"integer", "jsr30"=>"boolean", 
      "version"=>"string", "midiMonophonic"=>"boolean", "osOsx"=>"boolean", 
      "mpeg4InVideo"=>"boolean", "displayWidth"=>"integer", "qcelpInVideo"=>"boolean", 
      "usableDisplayHeight"=>"integer", "hscsd"=>"boolean", "memoryLimitMarkup"=>"integer", 
      "isFilter"=>"boolean", "drmOmaSeparateDelivery"=>"boolean", "cldc"=>"string", 
      "osLinux"=>"boolean", "gprs"=>"boolean", "aacInVideo"=>"boolean", "displayHeight"=>"integer", 
      "osWindows"=>"boolean", "amr"=>"boolean", "amrInVideo"=>"boolean", "isRobot"=>"boolean",
       "markup.xhtmlBasic10"=>"boolean", "midiPolyphonic"=>"boolean", "midp"=>"string", "id"=>"integer", 
       "osSymbian"=>"boolean", "scriptSupport"=>"string", "image.Jpg"=>"boolean", "jsr37"=>"boolean", 
       "qcelp"=>"boolean", "memoryLimitEmbeddedMedia"=>"integer"}
  end
  
  
  
end