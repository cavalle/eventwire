require 'bunny'
require 'amqp'
require 'amqp/extensions/rabbitmq'

class Eventwire::Adapters::SafeAMQP
  def initialize(options = {})
    @options = options
  end

  def publish(event_name, event_data = nil)
    connect_asynch do |conn|
      AMQP::Channel.new(conn) do |channel|
        channel.confirm_select
        channel.on_ack  do |basic_ack|
          channel.close
          stop
        end
        fanout = channel.fanout(event_name.to_s, :durable => true)
        fanout.publish(event_data, :persistent => true)
      end
    end
  end

  def subscribe(event_name, handler_id, &handler)
    subscriptions << [event_name, handler_id, handler]
  end

  def subscribe?(event_name, handler_id)
    subscriptions.any? {|s| s[0] == event_name && s[1] == handler_id }
  end

  def start
    connect_asynch do |conn|
      (@channel ||= AMQP::Channel.new(conn, AMQP::Channel.next_channel_id, :prefetch => 1)).tap do |channel|
        subscriptions.each {|subscription| bind_subscription(channel, *subscription) }
      end
    end
  end

  def stop
    AMQP.stop { EM.stop }
  end

  def purge
    connect_synch do |conn|
      subscriptions.group_by(&:first).each do |event_name, _|
        conn.exchange(event_name.to_s, :type => :fanout, :durable => true).delete
      end
      subscriptions.group_by(&:second).each do |handler_id, _|
        conn.queue(handler_id.to_s, :durable => true).delete
      end
    end
  end

  def subscriptions
    @subscriptions ||= []
  end

  def bind_subscription(channel, event_name, handler_id, handler)

    fanout = channel.fanout(event_name.to_s, :durable => true)
    queue  = channel.queue(handler_id.to_s, :durable => true)

    queue.bind(fanout).subscribe(:ack => true) do |metadata, json_data|
      metadata.ack
      handler.call json_data
    end
  end

  def connect_asynch(&block)
    if AMQP.connection && !AMQP.closing?
      block.call(AMQP.connection)
    else
      AMQP.start(@options, &block)
    end
  end

  def connect_synch(&block)
    Bunny.run(@options, &block)
  end

end
