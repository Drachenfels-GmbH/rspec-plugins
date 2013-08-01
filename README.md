rspec-plugins
=============

A simple plugin mechanism for RSpec.
Make your hooks reusable through a plugin module.

```ruby
include 'rspec-plugins'

class SimpleCounter < RSpec::Plugins::Base
  attr_accessor :count

  def initialize
    super
    @counter = 0
  end

  def increment(value = 1)
    @count += value
  end
end

RSpec::Plugins::Core.debug = true

describe SimpleCounter do
  include RSpec::Plugins::Core
  plugins.enable :counter => SimpleCounter.new

  plugin :counter, :increment
  plugin :counter, :increment, 5
end
```

# usage

Please please have a look at the specs for now [(Counter Plugin Spec)](spec/counter_plugin_spec.rb).

## debugging

To enable debugging:

```ruby
RSpec::Plugins::Core.debug = true
```