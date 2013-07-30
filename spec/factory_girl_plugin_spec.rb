require 'spec_helper'

describe RSpec::Plugins::FactoryGirlPlugin do

  include RSpec::Plugins::FactoryGirlPlugin
  metadata[:plugins][RSpec::Plugins::FactoryGirlPlugin].tap do |plugin|
    # configure the plugin here
  end

  context "with_fixture(:hello)" do
    with_fixture :hello
    with_fixture :hello1
    specify { true }
    context "with_fixture(:world)" do
      with_fixture :world
      specify { true }

      context "with_fixture(:rspec)" do
        with_fixture :rspec
        specify { true }
      end

      context "with_fixture(:foobar)" do
        with_fixture :foobar
        specify { true }
      end
    end
  end

  context "with_fixture(:foo)" do
    with_fixture :foo
    specify { true }
    context "with_fixture(:bar)" do
      with_fixture :bar
      specify { true }
    end
  end
end
