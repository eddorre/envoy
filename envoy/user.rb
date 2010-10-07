module Envoy
  class User
    def self.name
      `whoami`.delete("\n")
    end
  end
end