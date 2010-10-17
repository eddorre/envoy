module Envoy
  class NoTransportError < StandardError; end

  class Messenger
    attr_reader :all_transports
    attr_accessor :all_messages

    def initialize
      @all_transports = []
      @all_messages = []
    end

    def transport(transport_name, options = {})
      transport_instance = Module.const_get("Envoy").const_get(transport.to_s.capitalize).new(options)
      self.all_transports << transport_instance
    end

    def deliver_messages
      self.all_messages.each do |message|
        self.all_transports.each do |transport|
          transport.send_message(message)
        end
      end
    end

    def messages(message_options = nil, &block)
      if !message_options.nil?
        rescue ArgumentError if !message_options.is_a? Hash and return
        self.all_messages << Envoy::Message.new(message_options[:name], message_options[:subject], message_options[:body])
      else
        yield self if block_given?
      end
    end

    def message(message_options = {})
      message_options.symbolize_keys!
      self.all_messages << Envoy::Message.new(message_options[:name], message_options[:subject], message_options[:body])
    end

    def method_missing(method, *args)
      message = self.all_messages.select { |message| message.name == method.to_s.gsub('deliver_', '') }.first

      unless message.nil?
        self.all_transports.each do |transport|
          transport.send_message(message)
        end
      else
        super
      end
    end
  end
end