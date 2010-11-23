module Envoy
  class NoTransportError < StandardError; end

  class Messenger
    attr_accessor :_transports, :_messages, :_sent_messages

    def initialize
      self._transports = []
      self._messages = []
      self._sent_messages = []
    end

    def transports(transport_options = {}, &block)
      if !transport_options.empty?
        raise ArgumentError if !transport_options.is_a?(Hash) and return
        self._transports << self.transport(transport_options)
      else
        yield self if block_given?
      end
    end

    def transport(transport_options = {})
      transport_name = transport_options.delete(:name).to_s.capitalize
      begin
        transport_instance = Module.const_get("Envoy").const_get(transport_name).new(transport_options)
      rescue
        raise NoTransportError, "No transport exists for #{transport_name}" and return
      end
      self._transports << transport_instance
    end
    alias :add_transport :transport

    def deliver_messages
      self._messages.each do |message|
        self._transports.each do |transport|
          self.deliver_message(transport, message)
        end
      end
    end

    def deliver_message(transport, message)
      unless self._sent_messages.include?({ :transport => transport, :message => message })
        response = transport.send_message(message)
        self._sent_messages << { :transport => transport, :message => message } if response
      end
    end

    def messages(message_options = {}, &block)
      if !message_options.empty?
        raise ArgumentError if !message_options.is_a?(Hash) and return
        self._messages << self.message(message_options)
      else
        yield self if block_given?
      end
    end

    def message(message_options = {})
      message_options.symbolize_keys!
      self._messages << Envoy::Message.new(message_options[:name], message_options[:subject], message_options[:body])
    end
    alias :add_message :message

    def method_missing(method, *args)
      message = self._messages.select do |message|
        message.name.to_s.gsub(' ', '_').downcase == method.to_s.gsub('deliver_', '')
      end.first

      unless message.nil?
        self._transports.each do |transport|
          self.deliver_message(transport, message)
        end
      else
        super
      end
    end
  end
end