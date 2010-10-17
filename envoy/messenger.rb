module Envoy
  class NoTransportError < StandardError; end

  class Messenger
    attr_reader :transports
    attr_accessor :messages

    def initialize
      @transports = []
      @messages = []
    end

    def transport(transport, options = {})
      transport_instance = Module.const_get("Envoy").const_get(transport).new(options)
      self.transports << transport_instance
    end

    def deliver_messages
      self.messages.each do |message|
        self.transports.each do |transport|
          transport.send_messaage(message)
        end
      end
    end

    def method_missing(method, *args)
      message = self.messages.select { |message| message.name == method.to_s.gsub('deliver_', '') }.first

      unless message.nil?
        self.transports.each do |transport|
          transport.send_message(message)
        end
      else
        super
      end
    end
  end
end