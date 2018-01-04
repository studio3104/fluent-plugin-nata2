require 'fluent/plugin/in_tail'

class Fluent::MySQLSlowQueryExInput < Fluent::Plugin::TailInput
  Fluent::Plugin.register_input('mysqlslowquery_ex', self)

  config_param :dbname_if_missing_dbname_in_log, :string, default: nil
  config_param :last_dbname_file, :string, default: nil

  def initialize
    super
    require 'mysql-slowquery-parser'
  end

  def configure(conf)
    conf['format'] = 'none'
    super
    if conf['pos_file'] == @last_dbname_file
      raise Fluet::ConfigError, ''
    end
  end

  def start
    @last_dbname_of = if @last_dbname_file
                        @last_dbname_file_handle = File.open(@last_dbname_file, File::RDWR|File::CREAT, @file_perm)
                        @last_dbname_file_handle.sync = true
                        get_last_dbname()
                      else
                        {}
                      end
    super
  end

  def shutdown
    save_last_dbname()
    @last_dbname_file_handle.close if @last_dbname_file_handle
    super
  end

  def get_last_dbname
    return unless @last_dbname_file_handle
    @last_dbname_file_handle.pos = 0
    last_db = @last_dbname_file_handle.read.chomp
    begin
      JSON.parse(last_db, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end
  end

  def save_last_dbname
    return unless @last_dbname_file_handle
    current = get_last_dbname()
    unless current == @last_dbname_of
      @last_dbname_file_handle.pos = 0
      @last_dbname_file_handle.truncate(0)
      @last_dbname_file_handle.write(JSON.generate(current.merge(@last_dbname_of)))
    end
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
        log.warn %Q{in_mysqlslowquery_ex: parse error: #{$!.message}, (#{query_unit.to_s})}
        next
      end
      parsed_query = apply_dbname_to_record(parsed_query_unit)
      es.add(Fluent::EventTime.now.to_i, parsed_query)
      save_last_dbname()
    end

    if !es.empty?
      begin
        router.emit_stream(@tag, es)
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

  def apply_dbname_to_record(parsed_query)
    database_name = parsed_query[:db] || parsed_query[:schema] || @last_dbname_of[@path.to_sym] || @dbname_if_missing_dbname_in_log
    @last_dbname_of[@path.to_sym] = database_name
    parsed_query[:database] = database_name
    parsed_query.delete(:db)
    parsed_query.delete(:schema)
    parsed_query
  end
end
