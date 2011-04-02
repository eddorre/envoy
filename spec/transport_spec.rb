require 'envoy'
require 'fakeweb'
require 'spec_helper'
require 'timecop'
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
      @transport = Envoy::Email.new(:to => 'carlos@eddorre.com', :sender => 'carlos_sender@eddorre.com')
    end

    it "should send a message through sendmail binary" do
      @transport.host = :sendmail
      IO.should_receive(:popen).with("#{@transport.sendmail_binary} -f #{@transport.sender}, #{@transport.to}", "w+")
      @transport.send_message(@message)
    end

    it "should send a message through SMTP" do
      new_time = Time.local(2008, 9, 1, 12, 0, 0)
      Timecop.freeze(new_time)

      mail = TMail::Mail.new
      mail.to = @transport.to
      mail.from = @transport.sender
      mail.subject = @message.subject
      mail.date = Time.now
      mail.body = @message.subject

      TMail::Mail.stub!(:new).and_return(mail)

      @transport.host = 'mail.eddorre.com'

      @transport.send_message(@message)

      MockSMTP.deliveries[0][1].should == [@transport.sender]
      MockSMTP.deliveries[0][2].should == [@transport.to]
      MockSMTP.deliveries[0][0].should == mail.to_s

      Timecop.return
    end

    it "should return false when an exception is triggered" do
      @transport.host = :sendmail

      IO.stub!(:popen).and_raise(ArgumentError)

      @transport.send_message(@message).should == false
    end

    it "should return true when there is no exception triggered" do
      @transport.host = :sendmail

      IO.stub!(:popen).and_return

      @transport.send_message(@message).should == true
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

    it "should send a message to the webhook url and return false when the service doesn't return a 200" do
      FakeWeb.register_uri(:post, 'http://foo.com', :body => "Nothing here", :status => ["404", "Not Found"])
      @transport.send_message(@message).should == false
    end

    it "should add errors to the transport when an exception is raised" do
      Net::HTTP.stub!(:start).and_raise(Timeout::Error)
      FakeWeb.register_uri(:post, 'http://foo.com', :body => "Nothing here", :status => ["404", "Not Found"])
      @transport.send_message @message

      @transport.errors.should_not be_nil
    end
  end
end