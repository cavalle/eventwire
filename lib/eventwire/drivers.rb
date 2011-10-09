require 'json'

module Eventwire
  module Drivers
    autoload :InProcess, 'eventwire/drivers/in_process'
    autoload :AMQP,      'eventwire/drivers/amqp'
    autoload :Redis,     'eventwire/drivers/redis'
    autoload :Zero,      'eventwire/drivers/zero'
  end
end