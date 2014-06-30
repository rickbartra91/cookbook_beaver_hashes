# encoding: UTF-8
#
# outputs
sections = {}
conf = sections['beaver'] = {}
hash = 'node.beaver_hashes.output.to_hash'
logstash_server_ip = 'node.discover.logstash.ipaddress'
output_type = node['beaver_hashes']['output']['type']

case output_type
when 'rabbitmq' then
  #  host = hash['host'] || logstash_server_ip || 'localhost'
  conf['rabbitmq_host'] = hash['host'] if hash.key?('host')
  conf['rabbitmq_port'] = hash['port'] if hash.key?('port')
  conf['rabbitmq_vhost'] = hash['vhost'] if hash.key?('vhost')
  conf['rabbitmq_username'] = hash['user'] if hash.key?('user')
  conf['rabbitmq_password'] = hash['password'] if hash.key?('password')
  conf['rabbitmq_queue'] = hash['queue'] if hash.key?('queue')
  conf['rabbitmq_exchange_type'] = hash['rabbitmq_exchange_type'] if hash.key?('rabbitmq_exchange_type')
  conf['rabbitmq_exchange'] = hash['exchange'] if hash.key?('exchange')
  conf['rabbitmq_exchange_durable'] = hash['durable'] if hash.key?('durable')
  conf['rabbitmq_key'] = hash['key'] if hash.key?('key')
when 'redis' then
  host = hash['host'] || logstash_server_ip || 'localhost'
  port = hash['port'] || '6379'
  db = hash['db'] || '0'
  conf['redis_url'] = "redis://#{host}:#{port}/#{db}"
  conf['redis_namespace'] = hash['key'] if hash.key?('key')
when 'zmq' then
  host = hash['host'] || logstash_server_ip || 'localhost'
  port = hash['port'] || '2120'
  conf['zeromq_address'] = "tcp://#{host}:#{port}"
when 'stdout'
else
  fail "output type not supported: #{output_type}"
end

'node.beaver_hashes'.inputs.each do |path, opts|
  # beaver considers type manditory, and chef requires to be sure
  # that all the path keys are materialized
  fail 'all beaver_hashes inputs require a type' unless opts.key?('type')

  %w(tags add_field).each do |name|
    opts[name] = opts[name].join(',') if opts[name].is_a?(Array)
  end

  sections[path] = opts unless opts['disable'] == true
end

template 'node.beaver_hashes.config_file' do
  source 'beaver.conf.erb'
  mode 0640
  owner node['logstash']['user']
  group node['logstash']['group']
  # TODO: this is a python ini file. we should make a serializer
  # not use an erb template
  variables sections: sections
  notifies :restart, 'service[logstash_beaver]'
end
