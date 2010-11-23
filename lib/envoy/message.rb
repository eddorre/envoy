module Envoy
  class Message
    attr_accessor :name, :body, :subject, :options

    def initialize(name, subject, body = nil, options = {})
      self.name = name
      self.body = body
      self.subject = subject
      self.options = options
    end
  end
end