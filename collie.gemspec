# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "collie/version"

Gem::Specification.new do |s|
  s.name        = "collie"
  s.version     = Collie::VERSION
  s.authors     = ["Luismi Cavalle"]
  s.email       = ["luismi@lmcavalle.com"]
  s.homepage    = "http://github.com/cavalle/collie"
  s.summary     = %q{Event Collaboration for the Masses}
  s.description = %q{Generic interface to various backends (AMQP, Redis, ZeroMQ) to help building event-driven systems}

  s.rubyforge_project = "collie"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
