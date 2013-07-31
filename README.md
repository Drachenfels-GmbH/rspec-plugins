rspec-plugins
=============

A simple plugin mechanism for RSpec.

Make your hooks reusable through a plugin module or easily create a custom formatter.

Please have a look at the specs for now ;)


# plugin listener/hook/helper call order

* helper method code
* formatter registration in a before(:all) hook
* formatter event :example_group_started
* before(:all) hooks added from helpers
* formatter event :example_started
* after(:all) hooks added from helpers
* formatter event :example_group_finished
* formatter de-registration in an after(:all) hook

