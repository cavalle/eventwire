require 'bunny'

class Eventwire::Drivers::Bunny
  
  def publish(event_name, event_data = nil)
    Bunny.run do |mq|
      mq.exchange(event_name.to_s, :type => :fanout).publish(ActiveSupport::JSON.encode(event_data))
    end
  end

  def subscribe(event_name, handler_id, &handler)
    (subscriptions[event_name.to_s] ||= []) << handler
    handler_ids << handler_id
  end

  def start
    Bunny.run do |channel|
      queue  = channel.queue(queue_name)
      
      subscriptions.each do |event_name, handlers| 
        fanout = channel.exchange(event_name.to_s, :type => :fanout)
        queue.bind(fanout)
      end
      
      queue.subscribe do |msg|
        event_name = msg[:delivery_details][:exchange]
        event_data = msg[:payload]
        (subscriptions[event_name.to_s] || []).each do |handler|
          handler.call parse_json(event_data)
        end
      end
    end
  end

  def stop
    # TODO: Find a graceful way to stop Bunny's subscribe loop
  end
  
  def purge
    Bunny.run do |channel|
      subscriptions.each do |event_name, _|
        channel.exchange(event_name, :type => :fanout).delete
      end
      channel.queue(queue_name).delete
    end
  end
  
  def parse_json(json)
    json != 'null' && ActiveSupport::JSON.decode(json)
  end

  def subscriptions
    @subscriptions ||= {}
  end
  
  def handler_ids
    @handler_ids ||= []
  end
  
  def queue_name
    Digest::MD5.hexdigest(handler_ids.join(':'))
  end
  
end
