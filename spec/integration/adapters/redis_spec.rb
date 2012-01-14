require 'integration/adapters/adapters_helper'

describe_adapter Eventwire::Adapters::Redis do
  it_should_behave_like 'an adapter with single-process support'
  it_should_behave_like 'an adapter with multi-process support'
end
