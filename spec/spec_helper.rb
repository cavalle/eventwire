require 'rubygems'
require 'bundler'

Bundler.require

module Helpers
  def class_including(mod)
    Class.new.tap {|c| c.send :include, mod }
  end
  
  def eventually(timeout = 1, &block)
    start = Time.now
    while Time.now - start < timeout
      begin
        block.call
        break
      rescue RSpec::Expectations::ExpectationNotMetError
        sleep 0.001
      end
    end
  end
end

RSpec.configure do |config|
  config.include Delorean
  config.include Helpers
end

$:.unshift File.dirname(__FILE__) + '/..'
