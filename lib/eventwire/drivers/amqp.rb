require 'bunny'
require 'amqp'

class Eventwire::Drivers::AMQP
  
  class EMWrapper
    def stop
      EM.stop unless @reactor_running
    end
    
    def initialize(&block)
      @reactor_running = EM.reactor_running?
      if @reactor_running
        block.call(self)
      else
        EM.run { block.call(self) }
      end
    end
  end
  
  def publish(event_name, event_data = nil)
    EMWrapper.new do |em|
      connection = AMQP.connect
      channel  = AMQP::Channel.new(connection)
      channel.fanout(event_name.to_s).publish(event_data.to_json) do
        connection.close { em.stop }
      end
    end
  end

  def subscribe(event_name, handler_id, &handler)
    subscriptions << [event_name, handler_id, handler]
  end

  def start
    EMWrapper.new do |em|
      @em = em
      @connection = AMQP.connect
      AMQP::Channel.new(@connection) do |ch|
        subscriptions.each {|subscription| bind_subscription(*([ch] + subscription)) }
      end
    end
  end

  def stop
    @connection.close { @em.stop }
  end
  
  def purge
    Bunny.run do |mq|
      subscriptions.group_by(&:first).each do |event_name, _|
        mq.exchange(event_name, :type => :fanout).delete
      end
      subscriptions.group_by(&:second).each do |handler_id, _|
        mq.queue(handler_id).delete
      end
    end
  end
  
  def parse_json(json)
    json != 'null' && JSON.parse(json) 
  end

  def subscriptions
    @subscriptions ||= []
  end
  
  def bind_subscription(ch, event_name, handler_id, handler)   
    fanout = ch.fanout(event_name.to_s)
    queue  = ch.queue(handler_id.to_s)

    queue.bind(fanout).subscribe do |json_data|
      handler.call parse_json(json_data)
    end
  end
  
end
