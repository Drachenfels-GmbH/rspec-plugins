require 'spec_helper'
require 'rspec-plugins/fixture_plugin'


#ActiveRecord::Base.connection.tables.each do |table|
#  log.debug "Truncating #{table}"
#  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table};")
#end

class Foobar
  attr_accessor :loaded, :added, :reload_required

  def initialize
    @added = []
    @loaded = []
    @reload_required = false
    reset
  end

  def reload
    if @reload_required && ! @loaded.empty?
      puts "RELOAD #{@loaded}"
      @reloaded = @loaded
      @reload_required = false
    end
  end

  def load
    if ! @added.empty?
      puts "LOADING #{@added}"
      @loaded += @added
      @added = []
    end
  end

  def add(fixture_id)
    puts "ADD #{fixture_id}"
    @added << fixture_id
  end

  def remove(fixture_id)
    puts "REMOVE #{fixture_id}"
    @removed << @loaded.delete(fixture_id)
    @reload_required = true
  end

  attr_accessor :removed, :reloaded

  def reset
    @removed = []
    @reloaded = []
  end
end

# hooks installed by a plugin are called with the plugin instance
# as first parameter


# extend plugins ?
# change plugin implementation class ?
# reset particular plugin module settings when included ?
# -> it's not possible to use persistent but changed settings ?


# settings that can be changed before inclusion
# * plugin class

# settings that can be changed after inclusion
# * plugin class instance properties
# * extend plugin class instance with modules ?
# * what if a module overwrites a instance method

describe 'foo'
  # adds the methods to add plugin
  include RSpec::Plugins::Core

  plugins Foo.new, Bar.new, Baz.new

  # plugins method is also available on the example class

  #metadata[:plugins][RSpec::Plugins::FixturePlugin].tap do |plugin|
  #  plugin.fixture_manager = TrackingFixtureManager.new
  #end


# when included a new instance of Foobar is created
RSpec::Plugins::FixturePlugin.settings.plugin_class = Foobar

describe RSpec::Plugins::FixturePlugin do
  include RSpec::Plugins::FixturePlugin

  #initial plugin configuration
  #metadata[:plugins][RSpec::Plugins::FixturePlugin].tap do |plugin|
  #  plugin.fixture_manager = TrackingFixtureManager.new
  #end

  # reset fixture manager after each example
  let(:plugin) { example.metadata[:plugins][RSpec::Plugins::FixturePlugin] }
  #after(:all) { plugin.fixture_manager.reset }

  #before(:each) { puts "--> #{plugin.loaded}" }

  context "with_fixture(:hello), with_fixture(:hello1)" do
    with_fixture :hello
    with_fixture :hello1

    describe "plugin" do
      subject { plugin }
      its(:loaded) { should eq([:hello, :hello1]) }
      its(:removed) { should eq([]) }
      its(:reloaded) { should eq([]) }
    end

    context "with_fixture(:world)" do
      with_fixture :world

      describe "plugin" do
        subject { plugin }
        its(:loaded) { should eq([:hello, :hello1, :world]) }
        its(:removed) { should eq([]) }
        its(:reloaded) { should eq([]) }
      end
    end

    context "with_fixture(:rspec)" do
      with_fixture :rspec

      describe "plugin" do
        subject { plugin }
        its(:loaded) { should eq([:hello, :hello1, :rspec]) }
        its(:removed) { should eq([:world]) }
        its(:reloaded) { should eq([:hello, :hello1]) }
      end
    end
  end

  context "with_fixture(:rspec)" do
    with_fixture :rspec

    describe "plugin" do
      subject { plugin }
      its(:loaded) { should eq([:rspec]) }
      its(:removed) { should eq([]) }
      its(:reloaded) { should eq([]) }
    end
  end
end
