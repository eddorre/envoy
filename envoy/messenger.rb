module Envoy
  class NoTransportError < StandardError; end

  class Messenger
    attr_reader :transports

    def initialize
      @transports = []
    end

    def transport(transport, options = {})
      transport_instance = Module.const_get("Envoy").const_get(transport).new(options)
      self.transports << transport_instance
    end

    def deliver_start_message
      self.transports.each do |transport|
        transport.send_start_message(User.name)
      end
    end

    def deliver_end_message
    end
  end
end