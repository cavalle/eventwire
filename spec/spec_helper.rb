require 'rubygems'
require 'bundler'

Bundler.require

require 'eventwire'

Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each { |f| require f }
include Adapters

def sleep(time)
  factor = ENV['SLEEP_FACTOR'] || 1
  super time * factor.to_f
end

RSpec.configure do |config|
  config.include Delorean
  config.include Helpers
  
  config.after do
    Eventwire.reset!
  end
end

$:.unshift File.dirname(__FILE__) + '/..'
