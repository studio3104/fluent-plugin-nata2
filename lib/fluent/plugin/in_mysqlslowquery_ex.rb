class Fluent::MySQLSlowQueryExInput < Fluent::NewTailInput
  Fluent::Plugin.register_input('mysqlslowquery_ex', self)

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method(:log) { $log }
  end

  def initialize
    super
    require 'mysql-slowquery-parser'
  end

  def configure(conf)
    conf['format'] = 'none'
    super
  end

  def parser
    MySQLSlowQueryParser
  end

  def receive_lines(lines, tail_watcher)
    es = Fluent::MultiEventStream.new

    prepare_lines_to_parse(lines).each do |query_unit|
      begin
        parsed_query_unit = parser.parse_slow_log(query_unit)
      rescue
        log.warn %Q{in_mysqlslowquery_ex: parse error: #{$!.message}}
        next
      end
      es.add(Time.now.to_i, parsed_query_unit)
    end

    if !es.empty?
      begin
        Fluent::Engine.emit_stream(@tag, es)
      rescue
        # ignore errors. Engine shows logs and backtraces.
      end
    end
  end

  def prepare_lines_to_parse(lines, slow_queries = [])
    @query_unit = [] unless @query_unit
    while !lines.empty?
      line = lines.shift
      @query_unit << line
      if line.end_with?(';', ";\n") && !line.start_with?('use ', 'SET timestamp=')
        slow_queries << @query_unit
        @query_unit = nil
        prepare_lines_to_parse(lines, slow_queries)
        break # For when refactoring. Just in case.
      end
    end
    slow_queries
  end
end
