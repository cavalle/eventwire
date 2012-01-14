module Drivers
  def describe_driver(driver_class, &block)
    driver = driver_class.to_s.gsub(/^.*::/, '')
    describe(driver_class, &block) if should_be_tested?(driver)
  end

  def with_driver(driver, &block)
    if should_be_tested?(driver)
      context "using the #{driver} driver", &block
    end
  end

  def should_be_tested?(driver)
    return true if selected.nil? && excluded.nil?
    return selected?(driver) if selected
    return !excluded?(driver) if excluded
  end

  def selected
    ENV['ONLY'].split(',') if ENV['ONLY']
  end

  def excluded
    ENV['EXCEPT'].split(',') if ENV['EXCEPT']
  end

  def selected?(driver)
    selected.include?(driver)
  end

  def excluded?(driver)
    excluded.include?(driver)
  end
end