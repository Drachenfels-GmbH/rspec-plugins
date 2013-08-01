require 'spec_helper'

class CounterPlugin < RSpec::Plugins::Base
  attr_accessor :counter

  def initialize
    super
    @counter = 0
  end

  def increment
    @counter += 1
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
      its(:counter) { should eq(2) }
    end

    describe "plugin :counter2" do
      subject { plugins[:counter2] }
      its(:counter) { should eq(1) }
    end

    context "counter.increment 1, counter2.increment 2" do
      plugin :counter, :increment
      plugin :counter2, :increment
      plugin :counter2, :increment

      describe "plugin :counter" do
        subject { plugins[:counter] }
        its(:counter) { should eq(3) }
      end

      describe "plugin :counter2" do
        subject { plugins[:counter2] }
        its(:counter) { should eq(3) }
      end
    end
  end

  context "counter2.increment 2" do
    plugin :counter2, :increment
    plugin :counter2, :increment

    describe "plugin :counter" do
      subject { plugins[:counter] }
      its(:counter) { should eq(3) }
    end

    describe "plugin :counter2" do
      subject { plugins[:counter2] }
      its(:counter) { should eq(5) }
    end
  end
end

describe '-- #2 plugins' do
  include RSpec::Plugins::Core

  let(:plugins) { example.metadata[:plugins] }
  plugins.enable :counter => CounterPlugin.new

  describe "#plugins" do
    subject { plugins[:counter] }
    its(:counter) { should eq(0) }
  end

  describe "#plugins" do
    plugin :counter, :increment
    subject { plugins[:counter] }
    its(:counter) { should eq(1) }
  end
end