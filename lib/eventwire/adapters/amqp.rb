require 'bunny'
require 'amqp'

class Eventwire::Adapters::AMQP
  def initialize(options = {})
    @options = options
  end

  def publish(event_name, event_data = nil)
    connect_synch do |mq|
      mq.exchange(event_name.to_s, :type => :fanout).publish(event_data)
    end    
  end

  def subscribe(event_name, handler_id, &handler)
    subscriptions << [event_name, handler_id, handler]
  end

  def start
    connect_asynch do
      subscriptions.each {|subscription| bind_subscription(*subscription) }
    end
  end

  def stop
    AMQP.stop { EM.stop }
  end
  
  def purge
    connect_synch do |mq|
      subscriptions.group_by(&:first).each do |event_name, _|
        mq.exchange(event_name, :type => :fanout).delete
      end
      subscriptions.group_by(&:second).each do |handler_id, _|
        mq.queue(handler_id).delete
      end
    end
  end

  def subscriptions
    @subscriptions ||= []
  end
  
  def bind_subscription(event_name, handler_id, handler)   
    AMQP::Channel.new do |ch|
      fanout = ch.fanout(event_name.to_s)
      queue  = ch.queue(handler_id.to_s)

      queue.bind(fanout).subscribe do |json_data|
        handler.call json_data
      end
    end
  end

  def connect_asynch(&block)
    AMQP.start(@options, &block)
  end

  def connect_synch(&block)
    Bunny.run(@options, &block)
  end
  
end
