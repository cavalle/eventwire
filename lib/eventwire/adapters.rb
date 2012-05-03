module Eventwire
  module Adapters
    autoload :InProcess, 'eventwire/adapters/in_process'
    autoload :AMQP,      'eventwire/adapters/amqp'
    autoload :SafeAMQP,  'eventwire/adapters/safe_amqp'
    autoload :Bunny,     'eventwire/adapters/bunny'
    autoload :Redis,     'eventwire/adapters/redis'
    autoload :Mongo,     'eventwire/adapters/mongo'
  end
end
