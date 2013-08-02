require 'rspec/core'

module RSpec::Plugins
  module Core

    class NoPluginError < NameError; end

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
          proxy.dispatch(self, plugin_id, meth, *args, &block)
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

    def [](plugin_id)
      @plugins[plugin_id]
    end

    def enable(enable_plugins)
      proxy = self
      enable_plugins.each_pair do |key, plugin|
        Core.log "Add plugin :#{key}"
        plugin.proxy = proxy
        plugin.id = key
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

    def dispatch(current_example_group, plugin_id, meth, *args, &block)
      plugin = @plugins[plugin_id]
      if plugin
        current_example_group.before(:all) do
          plugin.current_example_group = current_example_group
          Core.log "Dispatching method :#{meth} to #{plugin}"
          plugin.dispatch(meth, *args, &block)
        end
      else
        raise Core::NoPluginError, "Plugin :#{plugin_id} not found. Available plugins: #{@plugins.keys}"
      end
    end
  end

  class Base
    attr_accessor :id, :enabled, :proxy, :current_example_group

    def initialize
      @id = nil
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

    def dispatch(meth, *args, &block)
      send meth, *args, &block
    end

  private
    def log(message)
      Core.log "plugin[#{id}]: #{message}"
    end

    def after(*args, &block)
      plugin = self
      @current_example_group.send :after, :all  do
        block.call(plugin, *args)
      end
    end
  end
end