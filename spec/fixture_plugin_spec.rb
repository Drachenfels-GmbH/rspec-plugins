require 'spec_helper'
require 'rspec-plugins/fixture_plugin'

class FixtureTestPlugin < RSpec::Plugins::FixturePlugin

  def reload(fixture_sym)
    log "RELOAD #{fixture_sym}"
    fixture_sym.to_s
  end

  def create(fixture_sym)
    log "CREATE #{fixture_sym}"
    fixture_sym.to_s
  end

  def truncate_tables
    log "TRUNCATE TABLES"
  end
end

RSpec::Plugins::Core.debug = true

describe RSpec::Plugins::FixturePlugin do
  include RSpec::Plugins::Core
  plugins.enable :fixtures => FixtureTestPlugin.new

  let(:plugin) { example.metadata[:plugins][:fixtures] }

  describe "plugin" do
    subject { plugin }
    its(:loaded) { should be_empty }
    its(:pending) { should be_empty }
    its(:unloaded) { should be_empty }
    its(:reloaded) { should be_empty }
  end

  context "load :rule, load :rule1" do
    plugin :fixtures, :load, :rule
    plugin :fixtures, :load, :rule1

    describe "plugin" do
      subject { plugin }
      its(:loaded) { should eq({:rule => 'rule', :rule1 => 'rule1'}) }
      its(:pending) { should be_empty }
      its(:unloaded) { should be_empty }
      its(:reloaded) { should be_empty }
    end

    context "load :rule2" do
      plugin :fixtures, :load, :rule2

      describe "plugin" do
        subject { plugin }
        its(:loaded) { should eq({:rule => 'rule', :rule1 => 'rule1', :rule2 => 'rule2'}) }
        its(:pending) { should be_empty }
        its(:unloaded) { should be_empty }
        its(:reloaded) { should be_empty }
      end
    end

    context "load :rule3" do
      plugin :fixtures, :load, :rule3

      describe "plugin" do
        subject { plugin }
        its(:loaded) { should eq({:rule => 'rule', :rule1 => 'rule1', :rule3 => 'rule3'}) }
        its(:pending) { should be_empty }
        its(:unloaded) { should be_empty }
        its(:reloaded) { should eq([:rule, :rule1]) }
      end
    end
  end

  context ":load :rule4, " do
    plugin :fixtures, :load, :rule4

    describe "plugin" do
      subject { plugin }
      its(:loaded) { should eq({:rule4 => 'rule4'}) }
      its(:pending) { should be_empty }
      its(:unloaded) { should be_empty }
      its(:reloaded) { should be_empty }
    end
  end
end
