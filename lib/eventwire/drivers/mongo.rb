require 'mongo'

class Eventwire::Drivers::Mongo
  DB_NAME = 'broker'
  
  def initialize
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

  def start
    @started = true
    
    loop do
      @handlers.each do |queue_name, handler|
        break unless @started
        queue = db.collection(queue_name)
        if event_data = queue.find_and_modify({:remove => true})
          handler.call event_data['event_data']
        end
      end
    end
  end

  def stop
    @started = false
  end

  def db
    @db ||= Mongo::Connection.new('localhost', 27017, :safe => true).db(DB_NAME)
  end

  def purge
    Mongo::Connection.new.drop_database(DB_NAME)
  end
  
end
