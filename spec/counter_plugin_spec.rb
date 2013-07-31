require 'spec_helper'

class CounterPlugin < RSpec::Plugins::Base
  attr_accessor :counter

  def initialize
    super
    @counter = 0
  end

  def increment
    puts "COUNT #{@counter}"
    after(@counter) do |plugin, captured_counter|
      puts "#{captured_counter} --> #{plugin.counter}"
    end
    @counter += 1
  end
end

describe '-- #1 plugins' do
  include RSpec::Plugins::Core

  let(:plugins) { example.metadata[:plugins] }
  plugins.enable :counter => CounterPlugin.new

  describe "#plugins" do
    plugin :counter, :increment
    plugin :counter, :increment

    subject { plugins[:counter] }
    its(:counter) { should eq(2) }

    describe "#plugins" do
      plugin :counter, :increment
      plugin :counter, :increment
      subject { plugins[:counter] }
      its(:counter) { should eq(4) }
    end

    describe "#plugins" do
      subject { plugins[:counter] }
      its(:counter) { should eq(4) }
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