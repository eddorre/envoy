# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "envoy/version"

Gem::Specification.new do |s|
  s.name        = "envoy"
  s.version     = Envoy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Carlos Rodriguez"]
  s.email       = ["carlos@eddorre.com"]
  s.homepage    = "http://github.com/eddorre/envoy"
  s.summary     = %q{A simple, extendable messaging system built for deployments}
  s.description = %q{A simple, extendable messaging system built for deployments}

  s.rubyforge_project = "envoy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "broach", "0.2.1"
  s.add_dependency "tmail", "1.2.7.1"
  s.add_dependency "tlsmail", "0.0.1" if RUBY_VERSION <= '1.8.6'

  s.add_development_dependency "rspec", "~> 2.1.0"
  s.add_development_dependency "fakeweb", "1.3.0"
end
