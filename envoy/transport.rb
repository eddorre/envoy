require 'broach'
require 'pony'
require 'i18n'

module Envoy
  class Transport
    attr_accessor :host, :username, :password

    def initialize(options = {})
      self.host = options[:host]
      self.username = options[:username]
      self.password = options[:password]
    end
  end

  class Campfire < Transport
    attr_accessor :host, :account, :token, :room, :use_ssl

    def initialize(options = {})
      super
      self.room = options[:room]
      self.username = options[:account]
      self.password = options[:token]
      self.use_ssl = options[:token]
    end

    def send_message(message)
      Broach.settings = { 'account' => self.username, 'token' => self.password, 'use_ssl' => self.use_ssl }
      Broach.speak(self.room, message.body || message.subject)
    end
  end

  class Mail < Transport
  attr_accessor :host, :username, :password, :sender, :to, :port, :ssl, :authentication

    def initialize(options = {})
      super
      self.host = options[:host]
      self.username = options[:username]
      self.sender = options[:sender]
      self.to = options[:to]
      self.port = options[:port] || 25
      self.ssl = options[:ssl] || false
      self.authentication = options[:authentication] || nil
    end

    def send_message(message)
      if @host.to_sym == :sendmail
        Pony.mail(:from => (@sender.nil? ? 'Envoy Messenger <envoymessenger@localhost>' : @sender),
          :to => (@to.is_a?(String) ? @to : @to.join(',')),
          :via => :sendmail, :body => message.body || message.subject, :subject => message.subject)
      else
        Pony.mail(:from => (@sender.nil? ? 'Envoy Messenger <envoymessenger@localhost>' : @sender),
          :to => (@to.is_a?(String) ? @to : @to.join(',')), :via => :smtp, :via_options =>
            {
              :address => @host, :port => @port, :enable_starttls_auto => @ssl, :user_name => @username,
              :password => @password, :authentication => @authentication, :body => message.body || message.subject, :subject => message.subject
            })
      end
    end
  end
end