require 'envoy'
require 'fakeweb'
include Envoy

describe Messenger do
  before(:each) do
    @messenger = Messenger.new
  end
  
  it "should create a new instance of a messenger" do
    @messenger.is_a?(Messenger).should be_true
  end
  
  describe "Adding messages" do
    it "should add an instance of a message" do
      @messenger.message(:name => 'Test message', :subject => 'Test subject')
      @messenger.all_messages.first.is_a?(Message).should be_true
    end
        
    it "should add a message with add_message method" do
      @messenger.add_message(:name => 'Test message', :subject => 'Test subject')
      @messenger.all_messages.size.should == 1
    end
    
    it "should add two messages" do
      @messenger.messages do |message|
        message.add_message(:name => 'Test message', :subject => 'Test subject')
        message.add_message(:name => 'Test message 2', :subject => 'Test subject 2')
      end
      @messenger.all_messages.size.should == 2
    end
  end
  
  describe "Adding transports" do
    it "should add an instance of a transport" do
      @messenger.transport(:name => :mail, :host => :sendmail, :to => 'carlos@eddorre.com')
      @messenger.all_transports.first.is_a?(Transport).should be_true
    end
    
    it "should add a transport with add_transport method" do
      @messenger.add_transport(:name => :mail, :host => :sendmail, :to => 'carlos@eddorre.com')
      @messenger.all_transports.size.should == 1
    end
    
    it "should add two transports" do
      @messenger.transports do |transport|
        transport.add_transport(:name => :mail, :host => :sendmail, :to => 'carlos@eddorre.com')
        transport.add_transport(:name => :campfire)
      end
      
      @messenger.all_transports.size.should == 2
    end
  end
  
  describe "Delivering messages" do
    it "should deliver a message by name" do
      Pony.stub!(:mail)
      @messenger.add_message(:name => 'Test message', :subject => 'Test subject')
      @messenger.add_transport(:name => :mail, :host => :sendmail, :to => 'carlos@eddorre.com')
      @messenger.all_transports.first.should_receive(:send_message)
      
      @messenger.deliver_test_message
    end
    
    it "should deliver all messages" do
      Pony.stub!(:mail)
      @messenger.add_message(:name => 'Test message', :subject => 'Test subject')
      @messenger.add_transport(:name => :mail, :host => :sendmail, :to => 'carlos@eddorre.com')
      @messenger.all_transports.first.should_receive(:send_message).with(@messenger.all_messages.first)
      
      @messenger.deliver_messages
    end
  end
end