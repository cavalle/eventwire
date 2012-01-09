module Helpers
  def class_including(mod)
    Class.new.tap {|c| c.send :include, mod }
  end
  
  def eventually(timeout = 1, &block)
    # Expectations must be met in less that timeout secs
    start = Time.now
    loop do
      begin
        block.call
        break
      rescue RSpec::Expectations::ExpectationNotMetError
        raise if Time.now - start > timeout
        sleep 0.001
      end
    end
    
    # Expectations must keep being met for at least 0.5 secs
    5.times { block.call; sleep 0.1 }
  end
end