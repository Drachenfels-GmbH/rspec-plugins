require 'spec_helper'

module TestPlugin
  include RSpec::Plugins::Core

  hook(:before, :all) do |plugin|
    plugin.storage.foobar = 'foobar'
  end

  helper(:set_value) do |plugin, example_group, key, value|
    example_group.before(:all) do
      plugin.storage.send "#{key}=".to_sym, value
    end
  end
end

describe "-- spec #1 --" do
  describe TestPlugin do
    include TestPlugin

    describe "#storage" do
      subject { storage }
      its(:foobar) { should eq('foobar')}

      describe "#storage" do
        subject { storage }
        its(:foobar) { should eq('foobar')}
      end
    end

    describe "store(:foobar, 'baz')" do
      set_value :foobar, 'baz'
      describe '#storage' do
        subject { storage }
        its(:foobar) { should eq('baz')}

        describe '#storage' do
          subject { storage }
          its(:foobar) { should eq('baz')}
        end
      end
    end

    describe '#storage' do
      subject { storage }
      its(:foobar) { should eq('baz')}
    end
  end
end

describe "-- spec #2 --" do
  describe TestPlugin do
    include TestPlugin
    describe '#storage' do
      subject { storage }
      its(:foobar) { should eq('foobar')}
    end
  end
end

