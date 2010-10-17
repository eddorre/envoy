module Envoy
  class Message
    attr_accessor :name, :body

    def initialize(name, body = nil)
      @name = name
      @body = body
    end
  end
end