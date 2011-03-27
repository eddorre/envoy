if RUBY_VERSION <= '1.8.6'
  begin
    require 'tlsmail'
  rescue LoadError
    raise "You need to install tlsmail if you are using ruby <= 1.8.6"
  end
end

require 'broach'
require 'net/http'
require 'uri'
require 'net/smtp'
require 'tmail'

module Envoy
  class Transport
    class SendError < RuntimeError
      attr_accessor :message, :created_at

      def initialize(message, created_at)
        self.message = message
        self.created_at = created_at
      end
    end

    attr_accessor :errors

    def initialize(*args)
      raise NotImplementedError, "This is an abstract class. You cannot instantiate this class directly."
    end

    def errors
      @errors ||= []
    end
  end

  class Campfire < Transport
    attr_accessor :account, :token, :room, :use_ssl

    def initialize(options = {})
      self.account = options[:account]
      self.room = options[:room]
      self.token = options[:token]
      self.use_ssl = options[:use_ssl]
    end

    def send_message(message)
      Broach.settings = { 'account' => @account, 'token' => @token, 'use_ssl' => @use_ssl }
      Broach.speak(self.room, message.body || message.subject)

      return true

      rescue Broach::APIError => error
        self.errors << SendError.new(error, Time.now)
        return false
    end
  end

  class Webhook < Transport
    attr_accessor :url, :headers

    def initialize(options = {})
      self.url = options[:url]
      self.headers = options[:headers] || {}
    end

    def send_message(message)
      url = URI.parse(@url)
      request = Net::HTTP::Post.new(url.path)
      request.body = message.options

      @headers.each do |k,v|
        request.add_field k,v
      end

      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

      case response
        when Net::HTTPSuccess, Net::HTTPFound
          return true
        else
          return false
      end

      rescue URI::InvalidURIError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
        self.errors << SendError.new(error, Time.now)
        return false
    end
  end

  class Email < Transport
    attr_accessor :host, :username, :password, :sender, :to, :port, :ssl, :authentication, :domain, :openssl_verify_mode

    def initialize(options = {})
      self.host = options[:host]
      self.username = options[:username]
      self.sender = options[:sender]
      self.password = options[:password]
      self.to = options[:to]
      self.port = options[:port] || 25
      self.ssl = options[:ssl] || false
      self.authentication = options[:authentication] || nil
      self.domain = options[:domain]
      self.openssl_verify_mode = options[:openssl_verify_mode]
    end

    def sendmail_binary
      sendmail = `which sendmail`.chomp
      (sendmail.nil? || sendmail == '') ? '/usr/bin/sendmail' : sendmail
    end

    def build_mail(message)
      mail = TMail::Mail.new
      mail.to = @to.is_a?(String) ? @to : @to.join(',')
      mail.from = @sender.nil? ? 'Envoy Messenger <envoymessenger@localhost>' : @sender
      mail.subject = message.subject
      mail.date = Time.now
      mail.body = message.body || message.subject

      mail
    end

    def build_connection
      smtp = Net::SMTP.new(@host, @port)

      if using_authentication?
        @openssl_verify_mode.nil? ? smtp.send(tls_mode) : smtp.send(tls_mode, @openss_verify_mode)
      end

      return smtp
    end

    def tls_mode
      RUBY_VERSION <= '1.8.6' ? "enable_tls" : "enable_starttls_auto"
    end

    def using_authentication?
      !@username.nil? && !@password.nil? && !@authentication.nil? && @ssl
    end

    def send_message(message)
      mail = self.build_mail(message)

      if @host.to_sym == :sendmail
        IO.popen("#{self.sendmail_binary} -f #{mail.from}, #{mail.to}", "w+") do |io|
          io.puts mail
          io.flush
        end
      else
        smtp = build_connection
        if using_authentication?
          smtp.start(@domain, @username, @password, @authentication.to_sym) do |smtp|
            smtp.sendmail mail.to_s, mail.from, mail.to
          end
        else
          smtp.start do |smtp|
            smtp.sendmail mail.to_s, mail.from, mail.to
          end
        end
      end

      return true

      rescue StandardError => error
        self.errors << SendError.new(error, Time.now)
        return false
    end
  end
end