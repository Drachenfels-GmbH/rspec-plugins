# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec-plugins/version'

s = Gem::Specification.new

s.name          = "rspec-plugins"
s.version       = Rspec::Plugins::VERSION
s.authors       = ["Ruben Jenster"]
s.email         = ["r.jenster@drachenfels.de"]
s.description   = %q{A plugin mechanism for RSpec}
s.summary       = %q{Make your hooks reusable through in a plugin module or easily create a custom formatter.}
s.homepage      = "http://github.com/Drachenfels-GmbH/rspec-plugins"

s.files         = `git ls-files`.split($/)
s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
s.test_files    = s.files.grep(%r{^(test|spec|features)/})
s.require_paths = ["lib"]
s.add_development_dependency "rake"

s.add_development_dependency "simplecov"
s.add_development_dependency "simplecov-rcov"

s

