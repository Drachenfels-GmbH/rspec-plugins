#require 'factory_girl'
require_relative 'core'

class FactoryGirl
  def self.create(factory_id)
    puts "CREATE #{factory_id}"
  end
end

module RSpec::Plugins::FactoryGirlPlugin
  include RSpec::Plugins::Core

  on :example_started do |plugin, example|
    plugin.reload
    plugin.load
    puts "Loaded fixtures: #{plugin.loaded_fixtures.keys}"
  end

  helper :with_fixture do |plugin, example_group, fixture_id|
    example_group.before(:all) { plugin.add(fixture_id) }
    example_group.after(:all) { plugin.remove(fixture_id) }
  end

  class Plugin
    attr_accessor :loaded_fixtures, :added_fixtures, :reload_fixtures
    attr_accessor :example_group, :plugin_module

    def initialize(example_group, plugin_module)
      @example_group    = example_group
      @plugin_module    = plugin_module
      @added_fixtures   = []
      @loaded_fixtures  = {}
      @removed_fixtures = {}
      @reload_fixtures  = false
    end

    def add(fixture_id)
      @added_fixtures << fixture_id
    end

    def remove(fixture_id)
      @removed_fixtures[fixture_id] = @loaded_fixtures.delete(fixture_id)
    end

    def load
      puts "... loading #{@added_fixtures}"
      @added_fixtures.each do |fixture_id|
        @loaded_fixtures[fixture_id] = FactoryGirl.create(fixture_id)

      end
      @added_fixtures.clear
    end

    def truncate_tables
      #ActiveRecord::Base.connection.tables.each do |table|
      #  log.debug "Truncating #{table}"
      #  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table};")
      #end
    end

    def reload_required?
      !@removed_fixtures.empty?
    end

    def reload
      if reload_required?
        truncate_tables
        puts "... reloading #{@loaded_fixtures.keys}"
        @loaded_fixtures.keys do |fixture_id|
          @loaded_fixtures[fixture_id].save
        end
      end
      @removed_fixtures.clear
    end
  end
end
