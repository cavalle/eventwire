require 'integration/adapters/adapters_helper'

describe_adapter Eventwire::Adapters::Bunny do
  it_should_behave_like 'a adapter with single-process support'
  it_should_behave_like 'a adapter with multi-process support'
end
