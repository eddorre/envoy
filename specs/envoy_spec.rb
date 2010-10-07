require 'envoy'

describe Envoy do
  describe "Creating a new messenger" do
    before(:each) do
      @messenger = Envoy::Messenger.new
    end
    
    it "should create a new instance of a messenger" do
      @messenger.is_a?(Envoy::Messenger).should == true
    end
    
    describe "Transports" do
      it "should have one transport" do
        @messenger.transport('Campfire', {})
        @messenger.transports.size.should == 1
      end
      
      it "should send a message through the Campfire Transport" do
        @messenger.transport('Campfire', { :account => 'eddorre', :token => '96553fa8d5215f8f5f29a564febb4ad806565857', :room => 'Work' })
        @messenger.deliver_start_message
      end
      
      it "should send a message through the SMTP Transport" do
        @messenger.transport('SMTP', { :sender => 'carlos@eddorre.com', :recipients => ['carlos@eddorre.com'] })
        @messenger.deliver_start_message
      end
    end    
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # describe "User" do
  #   it "should set a name" do
  #     Kernel.stub!(:`, 'whoami').and_return('foo')      
  #     Envoy::User.name.should == 'foo'
  #   end
  # end
  # 
  # describe "Git" do
  #   it "should print out what changed" do
  #     git_output = '83285ba5c59d34e623fa793cb70db2ba8727ca93 Testing commit stuff'
  #     
  #     Kernel.stub!(:`, 'git log').and_return(git_output)
  #     Envoy::Git.changes.should == git_output
  #   end
  # end
  
  it "should initialize a new transport" do
    envoy = Envoy::Transport.new
    envoy.is_a?(Envoy::Transport).should == true
  end
  
  describe "Setting Instance Variables" do
    before(:each) do
      @envoy = Envoy::Transport.new(:host => 'eddorre.com', :username => 'carlos', :password => 'test')
    end
    
    it "should set the host" do
      @envoy.host.should == 'eddorre.com'
    end
    
    it "should set the username" do
      @envoy.username.should == 'carlos'
    end
    
    it "should set the password" do
      @envoy.password.should == 'test'
    end
  end
  
  describe "Campfire Transport" do
    it "should initialize a new Campfire transport" do
      envoy = Envoy::Campfire.new
      envoy.is_a?(Envoy::Campfire).should == true
    end
    
    describe "Setting Instance Variables" do
      before(:each) do
        @envoy = Envoy::Campfire.new(:host => 'eddorre.com', :room => 'test_room')
      end
      
      it "should set the host" do
        @envoy.host.should == 'eddorre.com'
      end
      
      it "should set the room" do
        @envoy.room.should == 'test_room'
      end
      
      it "should set the username if an account option is passed in" do
        envoy = Envoy::Campfire.new(:account => 'carlos')
        envoy.username.should == 'carlos'
      end
      
      it "should set the password if an token option is passed in" do
        envoy = Envoy::Campfire.new(:token => 'test')
        envoy.password.should == 'test'
      end
    end
    
    describe "Sending start message" do
      before(:each) do
        @envoy = Envoy::Campfire.new(:account => 'test', :token => 'test', :room => 'developers')
        
        @env
      end
    end    
  end
end