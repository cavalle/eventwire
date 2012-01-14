require 'integration/adapters/adapters_helper'

describe_adapter Eventwire::Adapters::InProcess do
  it_should_behave_like 'an adapter with single-process support'
end
