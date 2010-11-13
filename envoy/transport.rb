require 'broach'
require 'pony'
require 'i18n'
require 'net/http'
require 'uri'

module Envoy
  class Transport
    def initialize(*args)
      raise NotImplementedError, "This is an abstract class. You cannot instantiate this class directly."
    end
  end

  class Campfire < Transport
    attr_accessor :account, :token, :room, :use_ssl

    def initialize(options = {})
      self.room = options[:room]
      self.token = options[:token]
      self.use_ssl = options[:use_ssl]
    end

    def send_message(message)
      Broach.settings = { 'account' => @account, 'token' => @token, 'use_ssl' => @use_ssl }
      Broach.speak(self.room, message.body || message.subject)
    end
  end

  class Webhook < Transport
    attr_accessor :url

    def initialize(options = {})
      self.url = options[:url]
    end

    def send_message(message)
      response = Net::HTTP.post_form(URI.parse(@url), message.options)

      case response
        when Net::HTTPSuccess
          return true
        else
          return false
      end
    end
  end

  class Email < Transport
    attr_accessor :host, :username, :password, :sender, :to, :port, :ssl, :authentication

    def initialize(options = {})
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

      return true

      rescue StandardError
        return false
    end
  end
end