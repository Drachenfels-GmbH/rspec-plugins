#require 'factory_girl'
require_relative 'core'

module RSpec::Plugins
  class FixturePlugin < RSpec::Plugins::Base

      attr_reader :loaded_fixtures, :added_fixtures, :reload_fixtures

      def initialize
        super
        @added_fixtures   = []
        @loaded_fixtures  = {}
        @removed_fixtures = {}
        @reload_fixtures  = false
      end

      def remove(fixture_id)
        @removed_fixtures[fixture_id] = @loaded_fixtures.delete(fixture_id)
      end

      def load
        log "... loading #{@added_fixtures}"
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

    def reload
      log "RELOAD"
    end

    def create(fixture_name)
      log "CREATE #{fixture_name}"
      nil
    end

    def truncate_tables
      puts "TRUNCATE TABLES"
    end

    def around(example)
        reload
        load
    end

    def add(fixture_id)
      @added_fixtures << fixture_id
      after do |plugin|
        plugin.remove(fixture_id)
      end
    end
  end
end
