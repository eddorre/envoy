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
    require 'broach'
    attr_accessor :host, :username, :password, :room

    def initialize(options = {})
      super
      @room = options[:room]
      @username = options[:account]
      @password = options[:token]
    end

    def send_start_message(user, options = {})
      branch_name = Envoy::Git.current_branch
      environment = 'production'
      Broach.settings = { 'account' => self.username, 'token' => self.password }
      Broach.speak(self.room, "#{user} is starting deployment of branch #{branch_name} to #{environment}")
    end
  end

  class SMTP < Transport
    require 'net/smtp'
    attr_accessor :host, :username, :password, :sender, :recipients

    def initialize(options = {})
      super
      @sender = options[:sender]
      @recipients = options[:recipients]
    end

    def send_start_message(user, options = {})
      branch_name = Envoy::Git.current_branch
      Net::SMTP.start(self.host || 'localhost') do |smtp|
        smtp.send_message "#{user} is starting deployment of branch #{branch_name} to #{environment}", self.sender,
          self.recipients
      end
    end
  end
end