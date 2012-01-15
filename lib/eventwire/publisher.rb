module Eventwire
  module Publisher
    def publish_event(event_name, event_data = nil)
      Eventwire.publish event_name.to_sym, event_data
    end
  end
end
