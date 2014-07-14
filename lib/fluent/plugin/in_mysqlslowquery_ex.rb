class Fluent::MySQLSlowQueryExInput < Fluent::NewTailInput
  Fluent::Plugin.register_output('mysqlslowquery_ex', self)

  config_param :suppress_sql_newline, :bool, default: false

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method(:log) { $log }
  end

  def initialize
    super
    require 'mysql-slowquery-parser'
  end

  def parser
    MySQLSlowQueryParser
  end

  def receive_lines(lines, tail_watcher)
    es = MultiEventStream.new
  end
end
