module Eventwire
  module Middleware
    class Base
      def initialize(app)
        @app = app
      end

      def method_missing(meth, *args, &blk)
        @app.send(meth, *args, &blk)
      end
    end
  end
end