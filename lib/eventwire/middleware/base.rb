require 'delegate'

module Eventwire
  module Middleware
    class Base < SimpleDelegator
      def initialize(app)
        @app = app
        super(app)
      end
    end
  end
end