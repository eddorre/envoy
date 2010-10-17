require 'broach'
require 'pony'

module Envoy
  class Transport
    attr_accessor :host, :username, :password

    def initialize(options = {})
      @host = options[:host]
      @username = options[:username]
      @password = options[:password]
    end
  end

  class Campfire < Transport
    attr_accessor :host, :username, :password, :room

    def initialize(options = {})
      super
      @room = options[:room]
      @username = options[:account]
      @password = options[:token]
    end

    def send_start_message(user, options = {})
      environment = 'production'
      Broach.settings = { 'account' => self.username, 'token' => self.password }
      Broach.speak(self.room, "#{user} is starting deployment of branch #{branch_name} to #{environment}")
    end
  end

  class Mail < Transport
  attr_accessor :host, :username, :password, :sender, :to, :port, :ssl, :authentication

    def initialize(options = {})
      super
      @sender = options[:sender]
      @to = options[:to]
      @port = options[:port] || 25
      @ssl = options[:ssl] || false
      @authentication = options[:authentication] || nil
    end

    def send_start_message(user, options = {})
      if @host == 'sendmail' || :sendmail
        Pony.mail(:from => 'Envoy Messenger <envoymessenger@localhost>', :to => @to.join(','), :via => :sendmail, :body => 'foo')
      else
        Pony.mail(:from => 'Envoy Messenger <envoymessenger@localhost>', :to => @to.join(','), :via => :smtp, :via_options => {
          :address => @host, :port => @port, :enable_starttls_auto => @ssl, :user_name => :username,
          :password => @password, :authentication => @authentication, :body => 'foo'
        })
      end
    end
  end
end