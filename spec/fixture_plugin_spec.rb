require 'spec_helper'
require 'rspec-plugins/fixture_plugin'


#ActiveRecord::Base.connection.tables.each do |table|
#  log.debug "Truncating #{table}"
#  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table};")
#end

class FixtureTestPlugin < RSpec::Plugins::FixturePlugin

end

describe RSpec::Plugins::FixturePlugin do
  include RSpec::Plugins::Core
  plugins.enable :fixtures => FixtureTestPlugin.new
  
  let(:plugin) { example.metadata[:plugins][:fixtures] }

  context ":load :hello, :helllo1" do
    plugin :fixtures, :load, :hello
    plugin :fixtures, :load, :hello1

    describe "plugin" do
      subject { plugin }
      its(:loaded_fixtures) { should eq([:hello, :hello1]) }
      #its(:removed) { should eq([]) }
      #its(:reloaded) { should eq([]) }
    end

    #context "with_fixture(:world)" do
    #  plugin :fixture, :load, :world
    #
    #  describe "plugin" do
    #    subject { plugin }
    #    its(:loaded) { should eq([:hello, :hello1, :world]) }
    #    its(:removed) { should eq([]) }
    #    its(:reloaded) { should eq([]) }
    #  end
    #end
    #
    #context "with_fixture(:rspec)" do
    #  plugin :fixture, :load, :rspec
    #
    #  describe "plugin" do
    #    subject { plugin }
    #    its(:loaded) { should eq([:hello, :hello1, :rspec]) }
    #    its(:removed) { should eq([:world]) }
    #    its(:reloaded) { should eq([:hello, :hello1]) }
    #  end
    end
  end

  #context "with_fixture(:rspec)" do
  #  plugin :fixture, :load, :rspec
  #
  #  describe "plugin" do
  #    subject { plugin }
  #    its(:loaded) { should eq([:rspec]) }
  #    its(:removed) { should eq([]) }
  #    its(:reloaded) { should eq([]) }
  #  end
  #end
#end
