module Adapters
  def describe_adapter(adapter_class, &block)
    adapter = adapter_class.to_s.gsub(/^.*::/, '')
    describe(adapter_class, &block) if should_be_tested?(adapter)
  end

  def with_adapter(adapter, &block)
    if should_be_tested?(adapter)
      context "using the #{adapter} adapter", &block
    end
  end

  def should_be_tested?(adapter)
    return true if selected.nil? && excluded.nil?
    return selected?(adapter) if selected
    return !excluded?(adapter) if excluded
  end

  def selected
    ENV['ONLY'].split(',') if ENV['ONLY']
  end

  def excluded
    ENV['EXCEPT'].split(',') if ENV['EXCEPT']
  end

  def selected?(adapter)
    selected.include?(adapter)
  end

  def excluded?(adapter)
    excluded.include?(adapter)
  end
end
