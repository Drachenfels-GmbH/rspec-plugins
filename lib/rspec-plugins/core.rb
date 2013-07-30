require 'rspec/core'
require 'ostruct'

=begin
        * listener registration before(:all)
        * example_group_started
        * before(:all) methods added from helpers
        * example_started
        * after(:all) methods added from helpers
        * example_group_finished
        * listener de-registration after(:all)
=end

module RSpec::Plugins
  module Core

    # This module holds the class methods for the plugin module.
    def self.included(plugin_module)
      plugin_module.extend(ClassMethods)

      plugin_module.define_singleton_method :included do |example_group|

        plugin = plugin_module::Plugin.new(example_group, plugin_module)
        example_group.metadata[:plugins] ||= {}
        example_group.metadata[:plugins][plugin_module] = plugin

        settings = plugin_module.settings

        # -- define helper methods
        settings.helpers.values.each do |helper|
          example_group.define_singleton_method helper.signal do |*args|
            helper.block.call(plugin, self, *args)
          end
        end

        # -- define listener for formatter events --
        settings.listeners.values.each do |listener|
          plugin.define_singleton_method(listener.signal) do |*args|
            listener.block.call(plugin, *args)
          end
        end

        # -- define rspec hooks --
        # formatters must be registered and de-registered to let them run per spec
        # register formatter listeners before all other hooks
        example_group.send :before, :all do
          RSpec.configure do |config|
            config.reporter.register_listener plugin, *settings.listeners.keys
          end
        end
        # -- register additional hooks
        settings.hooks.each do |hook|
          example_group.send hook.position, hook.target do |*args|
            hook.block.call(plugin, *args)
          end
        end
        # remove formatters after all other hooks
        example_group.send :after, :all do
          RSpec.configure do |config|
            settings.listeners.keys.each do |signal|
              config.reporter.registered_listeners(signal).delete(plugin)
            end
          end
        end
      end
    end

    def method_missing(symbol, *args, &block)
      listener = respond_to_missing?(symbol, false)
      if listener
        return listener.block.call(self, *args)
      else
        raise NoMethodError, "non existing method called: #{symbol}"
      end
    end

    def respond_to_missing?(symbol, include_private)
      methods.index(:plugin_module) && plugin_module.settings.listeners[symbol]
    end

    class Hook
      attr_accessor :position, :target, :block
      def initialize(method, target, &block)
        @position = method
        @target = target
        @block = block
      end
    end

    class Listener
      attr_accessor :signal, :block
      def initialize(signal, &block)
        @signal = signal
        @block = block
      end
    end

    module ClassMethods
      def settings
        id = self.to_s.to_sym
        Thread.current[id] ||= OpenStruct.new(
            {:listeners    => {},
             :helpers      => {},
             :hooks        => [],
             :id          => id
            })
      end

      def hook(position, target, &block)
        settings.hooks << Hook.new(position, target, &block)
      end

      # Register a notification callback.
      # {RSpec Reporter Notifications}[rdoc-href:RSpec::Core::Reporter::NOTIFICATIONS]
      # for a list of available notifications. The :close notification is reserved for
      # the plugin cleanup hook.
      def on(signal, &block)
        settings.listeners[signal] = Listener.new(signal, &block)
      end

      # Register a helper method for the example group an example group helper method.
      # Call #helpers to get the list of defined helper methods.
      def helper(method_name, &block)
        settings.helpers[method_name] =  Listener.new(method_name, &block)
      end
    end
  end
end