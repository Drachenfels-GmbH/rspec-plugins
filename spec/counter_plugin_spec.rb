require 'spec_helper'

class CounterPlugin < RSpec::Plugins::Base
  attr_accessor :count, :count_after, :count_around

  def initialize
    super
    @count = 0
    @count_after = 0
    @count_around = 0
  end

  def around(example)
    @count_around += 1
  end

  def increment
    @count += 1
    after do |plugin|
      log "Setting @count_after to @count*2"
      plugin.count_after = @count*2
    end
  end
end

RSpec::Plugins::Core.debug = true

describe '-- #1 plugins' do
  include RSpec::Plugins::Core
  plugins.enable :counter => CounterPlugin.new
  plugins.enable :counter2 => CounterPlugin.new

  let(:plugins) { example.metadata[:plugins] }

  context "counter.increment 2, counter2.increment 1" do
    plugin :counter, :increment
    plugin :counter, :increment
    plugin :counter2, :increment

    describe "plugin :counter" do
      subject { plugins[:counter] }
      its(:id) { should eq(:counter) }
      its(:count) { should eq(2) }
      its(:count_after) { should eq(0) }
    end

    describe "plugin :counter2" do
      subject { plugins[:counter2] }
      its(:id) { should eq(:counter2) }
      its(:count) { should eq(1) }
      its(:count_after) { should eq(0) }
    end

    context "counter.increment 1, counter2.increment 2" do
      plugin :counter, :increment
      plugin :counter2, :increment
      plugin :counter2, :increment

      describe "plugin :counter" do
        subject { plugins[:counter] }
        its(:count) { should eq(3) }
        its(:count_after) { should eq(0) }
      end

      describe "plugin :counter2" do
        subject { plugins[:counter2] }
        its(:count) { should eq(3) }
        its(:count_after) { should eq(0) }
      end
    end
  end

  context "counter2.increment 2" do
    plugin :counter2, :increment
    plugin :counter2, :increment

    describe "plugin :counter" do
      subject { plugins[:counter] }
      its(:count) { should eq(3) }
      its(:count_after) { should eq(6) }
    end

    describe "plugin :counter2" do
      subject { plugins[:counter2] }
      its(:count) { should eq(5) }
      its(:count_after) { should eq(6) }
    end
  end
end

describe '-- #2 plugins' do
  include RSpec::Plugins::Core

  let(:plugins) { example.metadata[:plugins] }
  plugins.enable :counter => CounterPlugin.new

  describe "#plugins[:counter]" do
    subject { plugins[:counter] }
    its(:count) { should eq(0) }
    its(:count_after) { should eq(0) }
  end

  describe "#plugins[:counter]" do
    plugin :counter, :increment
    subject { plugins[:counter] }
    its(:count) { should eq(1) }
    its(:count_after) { should eq(0) }
  end
end

describe "-- #3 plugins" do
  include RSpec::Plugins::Core

  let(:plugins) { example.metadata[:plugins] }
  describe "fail if no plugin is enabled" do
    it "should fail" do
      expect {
        plugins.dispatch(:foobar, :mymethod, :arg1)
      }.to raise_error RSpec::Plugins::Core::NoPluginError
    end
  end
end