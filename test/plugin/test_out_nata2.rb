require 'helper'

class Nata2OutputTest < Test::Unit::TestCase
  CONFIG = %[
  ]

  def create_driver(conf = CONFIG_NAME, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::Nata2put, tag).configure(conf)
  end

  def test_configure
  end
end
