require 'integration/adapters/adapters_helper'

describe_adapter Eventwire::Adapters::Bunny do
  it_should_behave_like 'an adapter with single-process support'
  it_should_behave_like 'an adapter with multi-process support'

  describe 'with options given' do
    let(:options) { stub }

    subject { Eventwire::Adapters::Bunny.new(options) }

    it 'should connect with options on subscribe' do
      Bunny.should_receive(:run).with(options)
      subject.subscribe :event_name, :handler_id
      subject.start
    end

    it 'should connect with options on publish' do
      Bunny.should_receive(:run).with(options)
      subject.publish :event_name
    end

    it 'should connect with options on purge' do
      Bunny.should_receive(:run).with(options)
      subject.purge
    end
  end
end
