# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eventwire/version"

Gem::Specification.new do |s|
  s.name        = "eventwire"
  s.version     = Eventwire::VERSION
  s.authors     = ["Luismi Cavalle"]
  s.email       = ["luismi@lmcavalle.com"]
  s.homepage    = "http://github.com/cavalle/eventwire"
  s.summary     = %q{Event Collaboration for the Masses}
  s.description = %q{Generic and simple interface to various backends (AMQP, Redis, ZeroMQ) to help building event-driven systems}

  s.rubyforge_project = "eventwire"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
