require 'envoy'
require 'fakeweb'
include Envoy

describe Transport do
  before(:each) do
    @message = Message.new('Test message', 'this is a test message')
  end

  describe "Campfire Transport" do
    it "should send a message through broach" do
      transport = Campfire.new(:account => 'foo', :token => 'bar', :room => 'meep')
      Broach.should_receive(:speak).with(transport.room, @message.subject)
      transport.send_message(@message)
    end
  end

  describe "Email Transport" do
    before(:each) do
      @transport = Envoy::Email.new
      @transport.to = 'carlos@eddorre.com'
    end

    it "should send a message through pony" do
      @transport.host = :sendmail
      Pony.should_receive(:mail)
      @transport.send_message(@message)
    end

    it "should send a message through pony with sendmail" do
      @transport.host = :sendmail


      Pony.should_receive(:mail).with(:via => :sendmail, :from => 'Envoy Messenger <envoymessenger@localhost>',
      :to => 'carlos@eddorre.com', :body => @message.subject, :subject => @message.subject)

      @transport.send_message(@message)
    end

    it "should send a message through pony using SMTP" do
      @transport.host = 'mail.eddorre.com'

      Pony.should_receive(:mail).with(:from => 'Envoy Messenger <envoymessenger@localhost>', :to => 'carlos@eddorre.com', :via => :smtp, :via_options => { :address => @transport.host,
        :port => 25, :enable_starttls_auto => false, :user_name => nil, :password => nil, :authentication => nil,
        :body => @message.subject, :subject => @message.subject })

      @transport.send_message(@message)
    end

    it "should send a message through pony with multiple recipients" do
      @transport.to = ['carlos@eddorre.com', 'hello@eddorre.com']
      @transport.host = :sendmail

      Pony.should_receive(:mail).with(:via => :sendmail, :from => 'Envoy Messenger <envoymessenger@localhost>',
      :to => 'carlos@eddorre.com,hello@eddorre.com', :body => @message.subject, :subject => @message.subject)

      @transport.send_message(@message)
    end

    it "should send a message through pony with a set sender" do
      @transport.host = :sendmail
      @transport.sender = 'carlos@eddorre.com'

      Pony.should_receive(:mail).with(:via => :sendmail, :from => 'carlos@eddorre.com',
      :to => 'carlos@eddorre.com', :body => @message.subject, :subject => @message.subject)

      @transport.send_message(@message)
    end
  end

  describe "Webhook Transport" do
    before(:each) do
      @transport = Envoy::Webhook.new
      @transport.url = 'http://foo.com/'
    end

    it "should send a message to the webhook URL and return true when the service returns 200" do
      FakeWeb.register_uri(:post, 'http://foo.com', :body => "OK", :status => ["200", "OK"])
      @transport.send_message(@message).should == true
    end

    it "should send a messaged to the webhook url and return false when the service doesn't return a 200" do
      FakeWeb.register_uri(:post, 'http://foo.com', :body => "Nothing here", :status => ["404", "Not Found"])
      @transport.send_message(@message).should == false
    end
  end
end