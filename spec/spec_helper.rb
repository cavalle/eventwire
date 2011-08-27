require 'rubygems'
require 'bundler'

Bundler.require

module Helpers
  def class_including(mod)
    Class.new.tap {|c| c.send :include, mod }
  end
end

RSpec.configure do |config|
  config.include Delorean
  config.include Helpers
end

$:.unshift File.dirname(__FILE__) + '/..'
