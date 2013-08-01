require_relative 'core'

module RSpec::Plugins
  class FixturePlugin < RSpec::Plugins::Base

    # TODO embed status into a Fixture class ?
    attr_reader :pending, :loaded, :unloaded, :reloaded

    def initialize
      super
      @pending  = []
      @load_order = []
      @loaded   = {}
      @unloaded = {}
      @reloaded = []
    end

    # Marks the given fixture pending to next #migrate.
    # Schedules the fixture removal after the example group.
    def load(fixture_sym)
      @pending << fixture_sym
      after do |plugin|
        plugin.unload(fixture_sym)
      end
    end

    # Moves the fixture from loaded to unloaded.
    def unload(fixture_sym)
      log "unloading #{fixture_sym}"
      @unloaded[fixture_sym] = @loaded.delete(fixture_sym)
      @load_order.delete(fixture_sym)
    end

    def load_pending
      if ! @pending.empty?
        log "load pending #{@pending}"
        @pending.each do |fixture_sym|
          @loaded[fixture_sym] = create(fixture_sym)
          @load_order << fixture_sym
        end
        @pending.clear
      end
    end

    def migrate
      if ! @unloaded.empty?
        truncate_tables
        @reloaded.clear
        if ! @loaded.empty?
          log "Reloading fixtures: #{@load_order}"
          @load_order.each do |fixture_sym|
            @loaded[fixture_sym] = reload(fixture_sym)
            @reloaded << fixture_sym
          end
        end
        @unloaded.clear
      end
    end

    def around(example)
      migrate
      load_pending
      example.run
    end
  end
end
