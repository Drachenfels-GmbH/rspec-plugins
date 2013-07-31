require 'spec_helper'

module TestPlugin
  include RSpec::Plugins::Core

  class Plugin < RSpec::Plugins::Core::Plugin
    attr_accessor :foobar
  end

  hook(:before, :all) do |plugin|
    plugin.foobar = 'foobar'
  end

  helper(:set_foobar) do |plugin, example_group, value|
    example_group.before(:all) do
      plugin.foobar = value
    end
  end
end

describe "-- spec #1 --" do
  describe TestPlugin do
    include TestPlugin

    describe "#storage" do
      subject { example.metadata[:plugins][TestPlugin] }
      its(:foobar) { should eq('foobar')}

      describe "#storage" do
        subject { example.metadata[:plugins][TestPlugin] }
        its(:foobar) { should eq('foobar')}
      end
    end

    describe "store(:foobar, 'baz')" do
      set_foobar 'baz'
      describe '#storage' do
        subject { example.metadata[:plugins][TestPlugin] }
        its(:foobar) { should eq('baz')}

        describe '#storage' do
          subject { example.metadata[:plugins][TestPlugin] }
          its(:foobar) { should eq('baz')}
        end
      end
    end

    describe '#storage' do
      subject { example.metadata[:plugins][TestPlugin] }
      its(:foobar) { should eq('baz')}
    end
  end
end

describe "-- spec #2 --" do
  describe TestPlugin do
    include TestPlugin
    describe '#storage' do
      subject { example.metadata[:plugins][TestPlugin] }
      its(:foobar) { should eq('foobar')}
    end
  end
end

