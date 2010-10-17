require 'broach'
require 'pony'
require 'i18n'

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

    def send_message(message)
      Broach.settings = { 'account' => self.username, 'token' => self.password }
      Broach.speak(self.room, message.body)
    end

  end

  class Mail < Transport
  attr_accessor :host, :username, :password, :sender, :to, :port, :ssl, :authentication, :subject

    def initialize(options = {})
      super
      @sender = options[:sender]
      @to = options[:to]
      @port = options[:port] || 25
      @ssl = options[:ssl] || false
      @authentication = options[:authentication] || nil
    end

    def send_message(message)
      if @host == 'sendmail' || :sendmail
        Pony.mail(:from => 'Envoy Messenger <envoymessenger@localhost>', :to => @to.join(','),
          :via => :sendmail, :body => message.body, :subject => message.subject)
      else
        Pony.mail(:from => 'Envoy Messenger <envoymessenger@localhost>', :to => @to.join(','), :via => :smtp, :via_options => {
          :address => @host, :port => @port, :enable_starttls_auto => @ssl, :user_name => :username,
          :password => @password, :authentication => @authentication, :body => message.body
        })
      end
    end
  end
end