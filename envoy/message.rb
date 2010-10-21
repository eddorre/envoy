module Envoy
  class Message
    attr_accessor :name, :body, :subject

    def initialize(name, subject, body = nil)
      self.name = name
      self.body = body
      self.subject = subject
    end
  end
end