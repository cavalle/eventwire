source "http://rubygems.org"

gem 'rspec'
gem 'activesupport', :require => 'active_support/all'
gem 'i18n'
gem 'delorean'
gem 'rake'

# Drivers
gem 'amqp',     :require => false
gem 'bunny',    :require => false
gem 'redis',    :require => false
gem 'em-redis', :require => false

unless ENV['TRAVIS']
  gem 'ffi',      :require => false
  gem 'ffi-rzmq', :require => false
end

gem 'SystemTimer', :require => false, :platforms => :mri_18

# Specify your gem's dependencies in eventwire.gemspec
gemspec