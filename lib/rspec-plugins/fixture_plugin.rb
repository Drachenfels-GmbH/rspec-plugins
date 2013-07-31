#require 'factory_girl'
require_relative 'core'

module RSpec::Plugins
  module FixturePlugin

    class Plugin
      attr_reader :loaded_fixtures, :added_fixtures, :reload_fixtures
      attr_accessor :fixture_manager

      def initialize
        @added_fixtures   = []
        @loaded_fixtures  = {}
        @removed_fixtures = {}
        @reload_fixtures  = false
        @fixture_manager = NullFixtureManager.new
      end

      def add(fixture_id)
        @added_fixtures << fixture_id
      end

      def remove(fixture_id)
        @removed_fixtures[fixture_id] = @loaded_fixtures.delete(fixture_id)
      end

      def load
        #puts "... loading #{@added_fixtures}"
        @added_fixtures.each do |fixture_id|
          @loaded_fixtures[fixture_id] = @fixture_manager.create(fixture_id)

        end
        @added_fixtures.clear
      end

      def reload_required?
        !@removed_fixtures.empty?
      end

      def reload
        if reload_required?
          @fixture_manager.truncate_tables
          if ! @loaded_fixtures.empty?
            #puts "... reloading #{@loaded_fixtures.keys}"
            @loaded_fixtures.keys.each do |fixture_id|
              @fixture_manager.reload(@loaded_fixtures[fixture_id])
            end
          end
        end
        @removed_fixtures.clear
      end
    end

    class NullFixtureManager
      def create(fixture_name)
        puts "CREATE #{fixture_name}"
        fixture_name
      end

      def reload(fixture)
        puts "RELOAD #{fixture}"
      end

      def truncate_tables
        puts "TRUNCATE TABLES"
      end
    end

    include RSpec::Plugins::Core

    settings.plugin_class = Plugin

    hook :before, :each do |plugin, example|
      plugin.reload
      plugin.load
      #puts "Loaded fixtures: #{plugin.loaded_fixtures.keys}"
    end

    helper :with_fixture do |plugin, example_group, fixture_id|
      example_group.before(:all) { plugin.add(fixture_id) }
      example_group.after(:all) { plugin.remove(fixture_id) }
    end
  end
end
