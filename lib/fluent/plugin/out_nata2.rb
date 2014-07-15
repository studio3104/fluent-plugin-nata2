require 'fluent/mixin/rewrite_tag_name'

class Fluent::Nata2Output < Fluent::Output
  Fluent::Plugin.register_output('nata2', self)

  include Fluent::HandleTagNameMixin
  include Fluent::Mixin::RewriteTagName

  config_param :server, :string
  config_param :port, :integer

  def initialize
    super
    require 'net/http'
    require 'uri'
  end

  def configure(conf)
    super
    @url = 'http://' + @server + ':' + @port.to_s
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      emit_tag = tag.clone
      filter_record(emit_tag, time, record)
      service_name, host_name, database_name = prepare_data_to_post(emit_tag, record)
      post_to_nata2(service_name, host_name, database_name, record)
    end
    chain.next
  end

  def prepare_data_to_post(tag, record)
    tag = tag.split('.')
    service_name = tag.shift
    host_name = tag.join('.')
    database_name = record[:database] || record['database']
    [ service_name, host_name, database_name ]
  end

  def post_to_nata2(service_name, host_name, database_name, record)
    api = URI.parse(@url + %Q{/api/1/#{service_name}/#{host_name}/#{database_name}})
    begin
      request = Net::HTTP::Post.new(api.path)
      request.set_form_data(record)
      http = Net::HTTP.new(api.host, api.port)
      response = http.start.request(request)
    rescue IOError, EOFError, SystemCallError => e
      log.warn %Q{net/http POST raises exception: #{e.class}, '#{e.message}'}
    end
    if !response || !response.is_a?(Net::HTTPSuccess)
      log.warn %Q{failed to post to nata2: #{api}, sql: #{record[:sql]}, code: #{response && response.code}}
    end
  end
end
