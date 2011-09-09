class Eventwire::Drivers::InProcess
  def initialize
    @handlers = {}
  end
  
  def handlers(event_name)
    @handlers[event_name] ||= []
  end
  
  def publish(event_name, event_data = nil)
    handlers(event_name).each do |handler|
      handler.call event_data
    end
  end
  
  def subscribe(event_name, handler_id, &handler)
    handlers(event_name) << handler
  end
  
  def start; end
  def stop; end
  def purge; end
end