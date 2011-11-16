module Eventwire
  module Middleware
    autoload :Base, 'eventwire/middleware/base'
                            
    autoload :Logger,       'eventwire/middleware/logger'
    autoload :ErrorHandler, 'eventwire/middleware/error_handler'
    autoload :DataObjects,  'eventwire/middleware/data_objects'
    
    autoload :JSONSerializer,        'eventwire/middleware/json_serializer'
    autoload :BSONSerializer,        'eventwire/middleware/bson_serializer'
    autoload :MessagePackSerializer, 'eventwire/middleware/msgpack_serializer'
  end
end