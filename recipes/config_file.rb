# outputs
sections = {}
conf = sections['beaver'] = {}
hash = node.beaver_hashes.output.to_hash
logstash_server_ip = node.discover.logstash.ipaddress

case node.beaver_hashes.output.type
when "rabbitmq" then
  host = hash['host'] || logstash_server_ip || 'localhost'
  conf['rabbitmq_host'] = hash['host'] if hash.has_key?('host')
  conf['rabbitmq_port'] = hash['port'] if hash.has_key?('port')
  conf['rabbitmq_vhost'] = hash['vhost'] if hash.has_key?('vhost')
  conf['rabbitmq_username'] = hash['user'] if hash.has_key?('user')
  conf['rabbitmq_password'] = hash['password'] if hash.has_key?('password')
  conf['rabbitmq_queue'] = hash['queue'] if hash.has_key?('queue')
  conf['rabbitmq_exchange_type'] = hash['rabbitmq_exchange_type'] if hash.has_key?('rabbitmq_exchange_type')
  conf['rabbitmq_exchange'] = hash['exchange'] if hash.has_key?('exchange')
  conf['rabbitmq_exchange_durable'] = hash['durable'] if hash.has_key?('durable')
  conf['rabbitmq_key'] = hash['key'] if hash.has_key?('key')
when "redis" then
  host = hash['host'] || logstash_server_ip || 'localhost'
  port = hash['port'] || '6379'
  db = hash['db'] || '0'
  conf['redis_url'] = "redis://#{host}:#{port}/#{db}"
  conf['redis_namespace'] = hash['key'] if hash.has_key?('key')
when "zmq" then
  host = hash['host'] || logstash_server_ip || 'localhost'
  port = hash['port'] || '2120'
  conf['zeromq_address'] = "tcp://#{host}:#{port}"
when 'stdout'
else
  raise "output type not supported: #{node.beaver_hashes.output.type}"
end

node.beaver_hashes.inputs.each do |path, opts|
  # beaver considers type manditory, and chef requires to be sure
  # that all the path keys are materialized
  raise "all beaver_hashes inputs require a type" unless opts.has_key?('type')

  [ 'tags', 'add_field' ].each do |name|
    opts[name] = opts[name].join(',') if opts[name].is_a?(Array)
  end

  sections[path] = opts unless opts['disable'] == true
end

template node.beaver_hashes.config_file do
  source 'beaver.conf.erb'
  mode 0640
  owner node['logstash']['user']
  group node['logstash']['group']
  # TODO this is a python ini file. we should make a serializer
  # not use an erb template
  variables :sections => sections
  notifies :restart, "service[logstash_beaver]"
end
