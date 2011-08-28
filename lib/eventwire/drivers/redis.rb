require 'redis'
require 'em-redis'

class Eventwire::Drivers::Redis
  def initialize
    @subscriptions = []
    @handlers      = []
  end
  
  def publish(event_name, event_data = nil)
    ::Redis.new.rpush event_name, event_data.to_json
  end

  def subscribe(event_name, handler_id = event_name, &handler)
    @subscriptions << [event_name.to_s, handler_id]
    @handlers << [handler_id, handler]
  end

  def start
    EM.run do
      @subscriptions.group_by(&:first).each do |event, subscriptions|
        subscribe_to_queue event do |data|
          subscriptions.each do |event, queue|
            redis = EM::Protocols::Redis.connect
            redis.rpush queue, data
          end
        end
      end

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
    EM.stop
  end
  
  def parse_json(json)
    json != 'null' && JSON.parse(json) 
  end
  
end