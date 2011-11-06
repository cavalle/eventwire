require 'redis'
require 'em-redis'

class Eventwire::Drivers::Redis
  def initialize
    @handlers = []
  end
  
  def publish(event_name, event_data = nil)
    redis = ::Redis.new
    handlers = redis.smembers("event_handlers:#{event_name}")
    handlers.each do |handler|
      redis.rpush handler, event_data.to_json
    end
  end

  def subscribe(event_name, handler_id, &handler)
    @handlers << [handler_id, handler]
    ::Redis.new.sadd "event_handlers:#{event_name}", handler_id
  end

  def start
    EM.run do
      @handlers.each do |queue, handler|
        subscribe_to_queue queue do |json_event|
          handler.call parse_json(json_event)
        end
      end 
    end
  end

  def subscribe_to_queue(queue, redis = nil, &block)
    redis ||= EM::Protocols::Redis.connect
    redis.blpop(queue, 0) do |response|
      block.call(response.last) if response
      subscribe_to_queue(queue, redis, &block)
    end
  end

  def stop
    EM.stop if EM.reactor_running?
  end
  
  def parse_json(json)
    json != 'null' && JSON.parse(json) 
  end
  
  def purge
    redis = ::Redis.new
    redis.flushdb
  end
  
end
