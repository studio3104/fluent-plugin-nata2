require 'helper'

class MySQLSlowQueryInputTest < Test::Unit::TestCase
  CONFIG = %[
  ]

  def create_driver(conf = CONFIG_NAME, tag='test')
    Fluent::Test::InputTestDriver.new(Fluent::MySQLSlowQueryExInput, tag).configure(conf)
  end

  def test_configure
  end
end
