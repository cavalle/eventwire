module Eventwire
  class Configuration

    attr_reader   :middleware, :error_handler
    attr_accessor :namespace, :logger

    def initialize
      @adapter = Adapters::AMQP.new
      @logger = Logger.new($stdout)
      @error_handler = lambda {|ex| }
      @middleware = [
        [ Eventwire::Middleware::ErrorHandler, self ],
        [ Eventwire::Middleware::Logger,       self ],
          Eventwire::Middleware::JSONSerializer,
          Eventwire::Middleware::DataObjects
      ]
    end

    def adapter=(adapter)
      klass = Adapters.const_get(adapter.to_sym) if adapter.respond_to?(:to_sym)
      @adapter = klass ? klass.new : adapter
    end

    def on_error(&block)
      @error_handler = block
    end

    def driver
      @middleware.inject(@adapter) do |driver, args|
        args  = Array(args).clone
        klass = args.shift
        klass.new(driver, *args)
      end
    end

  end
end
