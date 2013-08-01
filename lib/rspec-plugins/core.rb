require 'rspec/core'

module RSpec::Plugins
  module Core
    class << self
      attr_accessor :debug

      def debug?
        @debug ||= false
      end

      def log(message)
        debug? && puts(message)
      end

      def included(example_group)
        proxy = Proxy.new(example_group)
        example_group.metadata[:plugins] = proxy
        example_group.define_singleton_method(:plugins) { proxy }
        example_group.define_singleton_method :plugin do |plugin_id, meth, *args, &block|
          current_example_group = self
          plugin = proxy[plugin_id]
          if plugin.nil?
              raise("No plugin with id :#{plugin_id} enabled. Enabled plugins: #{proxy.plugins.keys}")
          else
            current_example_group.before(:all) do
              plugin.current_example_group = current_example_group
              Core.log("Calling plugin method #{plugin}##{meth}")
              plugin.send(meth, *args, &block)
            end
          end
        end
        log "Included RSpec::Plugins::Core in example group [#{example_group.description}]"
      end
    end
  end

  class Proxy
    attr_reader :plugins, :example_group

    def initialize(example_group)
      @example_group = example_group
      @plugins = {}
    end

    def [](key)
      @plugins[key]
    end

    def enable(enable_plugins)
      proxy = self
      enable_plugins.each_pair do |key, plugin|
        Core.log "Add plugin :#{key}"
        plugin.proxy = proxy
        # TODO check for duplicates
        @plugins[key] = plugin
        @example_group.send :before, :all do |running_example_group|
          plugin.current_example_group = running_example_group
          plugin.enable
          Core.log "Enabled plugin :#{key}"
        end
        if plugin.respond_to?(:around)
          @example_group.send :around, :each do |example|
            Core.log "Calling #{plugin}#around"
            plugin.around(example)
          end
        end
        @example_group.send :after, :all do |running_example_group|
          plugin.current_example_group = running_example_group
          plugin.disable
          proxy.plugins.delete(key)
          Core.log "Disabled plugin :#{key}"
        end
      end
    end
  end

  class Base
    attr_accessor :enabled, :proxy, :current_example_group

    def log(message)
      Core.log(message)
    end

    def initialize
      @enabled = false
      @proxy = nil
      @current_example_group = nil
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end

    def after(*args, &block)
      plugin = self
      @current_example_group.send :after, :all  do
        block.call(plugin, *args)
      end
    end
  end
end