require 'bunny'
require 'amqp'

class Eventwire::Drivers::AMQP
  def publish(event_name, event_data = nil)
    Bunny.run do |mq|
      mq.exchange(event_name, :type => :fanout).publish(event_data.to_json)
    end    
  end

  def subscribe(event_name, handler_id = event_name, &handler)
    subscriptions << lambda { |mq|
      fanout = mq.fanout(event_name)
      mq.queue(handler_id, :durable => true).bind(fanout).subscribe do |json_data|
        handler.call parse_json(json_data) 
      end
    }
  end

  def start
    AMQP.start do
      subscriptions.each { |s| s.call(MQ) }
    end
  end

  def stop
    AMQP.stop { EM.stop }
  end
  
  def parse_json(json)
    json != 'null' && JSON.parse(json) 
  end

  def subscriptions
    @subscriptions ||= []
  end
  
end