module Eventwire
  class Configuration

    attr_reader :driver, :error_handler

    attr_accessor :middleware, :namespace, :logger

    def initialize
      @driver = Drivers::InProcess.new
      @logger = Logger.new(nil)
      @error_handler = lambda{|ex| }
      @middleware = [[Eventwire::Middleware::ErrorHandler, {:error_handler => error_handler, :logger => logger}],
                     [Eventwire::Middleware::Logger, {:logger => logger}],
                     Eventwire::Middleware::JSONSerializer,
                     Eventwire::Middleware::DataObjects]
      @decorated = false
    end

    def driver=(driver)
      klass = Drivers.const_get(driver.to_sym) if driver.respond_to?(:to_sym)
      @driver = klass ? klass.new : driver
    end

    def on_error(&block)
      @error_handler = block
    end

    def decorated?
      !!@decorated
    end

    def decorate
      @decorated = true
      @driver = middleware.inject(driver) do |driver, args|
        args = Array(args)
        klass = args.shift
        if args && args.any?
          klass.new(driver, *args)
        else
          klass.new(driver)
        end
      end
    end

  end
end