source "http://rubygems.org"

gem 'rspec', '2.8'
gem 'activesupport', :require => 'active_support/all'
gem 'i18n'
gem 'delorean'
gem 'rake'
gem 'bson_ext'
gem 'hashie'

unless ENV["CI"]
  gem 'ruby-debug',   :platforms => :mri_18
  gem 'debugger', :platforms => :mri_19
end

# Drivers
gem 'amqp',     :require => false
gem 'bunny',    :require => false
gem 'redis',    :require => false
gem 'em-redis', :require => false
gem 'mongo',    :require => false

# Middleware
gem 'json',    :require => false
gem 'msgpack', :require => false

gem 'SystemTimer', :require => false, :platforms => :mri_18

# Specify your gem's dependencies in eventwire.gemspec
gemspec
