module Eventwire
  module Middleware
    autoload :Base, 'eventwire/middleware/base'
                            
    autoload :Logger,       'eventwire/middleware/logger'
    autoload :ErrorHandler, 'eventwire/middleware/error_handler'
    autoload :DataObjects,  'eventwire/middleware/data_objects'
  end
end