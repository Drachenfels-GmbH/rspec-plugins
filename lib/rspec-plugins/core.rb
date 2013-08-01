require 'rspec/core'
require 'ostruct'

module RSpec::Plugins
  module Core
    def self.included(example_group)
      plugins = Proxy.new(example_group)
      example_group.metadata[:plugins] = plugins
      example_group.define_singleton_method(:plugins) { plugins }
      example_group.define_singleton_method :plugin do |plugin_id, meth, *args, &block|
        current_example_group = self
        plugin = plugins[plugin_id]
        current_example_group.before(:all) do
          plugin.current_example_group = current_example_group
          plugin.send(meth, *args, &block)
        end
      end
      puts "Enabled RSpec::Plugins"
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
        puts "Add plugin :#{key} to #{self}"
        plugin.proxy = proxy
        # TODO check for duplicates
        @plugins[key] = plugin
        @example_group.send :before, :all do |running_example_group|
          puts "Enable plugin: #{key}"
          plugin = proxy.plugins[key]
          plugin.current_example_group = running_example_group
          plugin.enable
        end
        @example_group.send :after, :all do |running_example_group|
          puts "Disable plugin: #{key}"
          plugin = proxy.plugins[key]
          plugin.current_example_group = running_example_group
          plugin.disable
          proxy.plugins.delete(key)
        end
      end
    end
  end

  class Base
    attr_accessor :enabled, :proxy, :current_example_group

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