module Envoy
  class Message
    attr_accessor :name, :body, :subject

    def initialize(name, subject, body = nil)
      @name = name
      @body = body
      @subject = subject
    end
  end
end