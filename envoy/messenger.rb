module Envoy
  class NoTransportError < StandardError; end

  class Messenger
    attr_accessor :__transports
    attr_accessor :__messages

    def initialize
      self.__transports = []
      self.__messages = []
    end

    def transports(transport_options = {}, &block)
      if !transport_options.empty?
        raise ArgumentError if !transport_options.is_a?(Hash) and return
        self.__transports << self.transport(transport_options)
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
      self.__transports << transport_instance
    end
    alias :add_transport :transport

    def deliver__messages
      self.__messages.each do |message|
        self.__transports.each do |transport|
          transport.send_message(message)
        end
      end
    end

    def messages(message_options = {}, &block)
      if !message_options.empty?
        raise ArgumentError if !message_options.is_a?(Hash) and return
        self.__messages << self.message(message_options)
      else
        yield self if block_given?
      end
    end

    def message(message_options = {})
      message_options.symbolize_keys!
      self.__messages << Envoy::Message.new(message_options[:name], message_options[:subject], message_options[:body])
    end
    alias :add_message :message

    def method_missing(method, *args)
      message = self.__messages.select do |message|
        message.name.gsub(' ', '_').downcase == method.to_s.gsub('deliver_', '')
      end.first

      unless message.nil?
        self.__transports.each do |transport|
          transport.send_message(message)
        end
      else
        super
      end
    end
  end
end