require 'ffi-rzmq'

class Eventwire::Drivers::Zero
  def publish(event_name, event_data = nil)
    ctx = ZMQ::Context.new
    s = ctx.socket ZMQ::PUSH
    s.connect("tcp://127.0.0.1:5560")
    s.send_string([event_name, event_data].to_json)
    s.close
    ctx.terminate
  end

  def subscriptions(event_name)
    @subscriptions ||= Hash.new
    @subscriptions[event_name.to_s] ||= Set.new
  end

  def subscribe(event_name, handler_id, &handler)
    subscriptions(event_name.to_s) << handler
  end

  def start
    ctx = ZMQ::Context.new
    s = ctx.socket ZMQ::PULL
    s.bind("tcp://127.0.0.1:5560")
    @running = true
    while @running
      json_data = s.recv_string(ZMQ::NOBLOCK)
      next unless json_data
      event_name, event_data = parse_json(json_data)
      subscriptions(event_name).each do |subscription|
        subscription.call(event_data)
      end
    end
  ensure
    s.close
    ctx.terminate
  end

  def stop
    @running = false
  end
  
  def parse_json(json)
    json != 'null' && JSON.parse(json) 
  end
  
  def purge; end
  
end