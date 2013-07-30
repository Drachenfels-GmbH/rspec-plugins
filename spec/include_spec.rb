require 'spec_helper'

INCLUDED_PLUGINS = []
EXAMPLE_GROUPS   = []

module TestPlugin
  include RSpec::Plugins::Core

  helper(:save_plugin_and_example_group) do |plugin, example_group|
    INCLUDED_PLUGINS << plugin
    EXAMPLE_GROUPS << example_group
  end
end

describe TestPlugin do
  context "include #1" do
    include TestPlugin
    save_plugin_and_example_group

    describe "INCLUDED_PLUGINS" do
      subject { INCLUDED_PLUGINS }
      its(:length) { should be(2) }
      describe "INCLUDED_PLUGINS[0]" do
        subject { INCLUDED_PLUGINS[0] }
        it "should not equal INCLUDED_PLUGINS[1]" do
          should_not be(INCLUDED_PLUGINS[1])
        end
      end
    end

    describe "EXAMPLE_GROUPS" do
      subject { EXAMPLE_GROUPS }
      its(:length) { should be(2) }
      describe "EXAMPLE_GROUPS[0]" do
        subject { EXAMPLE_GROUPS[0] }
        it "should not equal EXAMPLE_GROUPS[1]" do
          should_not be(EXAMPLE_GROUPS[1])
        end
      end
    end
  end

  context "include #2" do
    include TestPlugin
    save_plugin_and_example_group
  end
end
