require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
                SimpleCov::Formatter::HTMLFormatter,
                SimpleCov::Formatter::RcovFormatter,
            ]
  add_filter "/spec/"
end

require "rspec"
require_relative "../lib/rspec-plugins"

RSpec.configure do |config|
  config.color_enabled = true
end
