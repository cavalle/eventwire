require 'mongo'

class Eventwire::Adapters::Mongo
  DEFAULT_OPTIONS = {:host => 'localhost', :port => 27017, 
                     :safe => true, :db_name => 'broker',
                     :pool_timeout => 5, :pool_size => 5 }
  
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @handlers = []
  end

  def publish(event_name, event_data = nil)
    collection = db.collection('event_handlers')
    collection.find(:event_name => event_name).each do |handler|
      queue = db.collection(handler['handler'])
      queue.save({:event_data => event_data})
    end
  end

  def subscribe(event_name, handler_id, &handler)
    @handlers << [handler_id, handler]
    
    collection = db.collection('event_handlers')
    collection.find_and_modify :query =>  {:handler => handler_id},
                               :update => {:handler => handler_id, :event_name => event_name},
                               :upsert => true
  end

  def subscribe?(event_name, handler_id)
    @handlers.any? { |h| h.first == handler_id }
  end

  def start
    @started = true
    
    loop do
      @handlers.each do |queue_name, handler|
        queue = db.collection(queue_name)
        if event_data = queue.find_and_modify({:remove => true})
          handler.call event_data['event_data']
        end
      end
      break unless @started
    end
  end

  def stop
    @started = false
  end

  def db
    @db ||= Mongo::Connection.new(host, port, options).db(db_name)
  end

  def purge
    Mongo::Connection.new(host, port, options).drop_database(db_name)
  end

  private

  def host
    @options[:host]
  end

  def port
    @options[:port]
  end

  def options
    { :safe => @options[:safe], :pool_timeout => @options[:pool_timeout], :pool_size => @options[:pool_size] }
  end
  
  def db_name
   @options[:db_name]
  end
  
end
