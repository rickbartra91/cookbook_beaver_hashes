default['beaver_hashes']['pip_package'] = "beaver==22"
default['beaver_hashes']['zmq']['pip_package'] = "pyzmq==2.1.11"
default['beaver_hashes']['inputs']["/var/log/*.log"]["type"] =  "varlog"
default['beaver_hashes']['output']['type'] = 'stdout'
default['beaver_hashes']['user'] = 'logstash'
default['beaver_hashes']['group'] = 'logstash'
default['beaver_hashes']['format'] = "json"

default['beaver_hashes']['basedir'] = '/opt/logstash/beaver'
default['beaver_hashes']['config_file'] = File.join(node.beaver_hashes.basedir, 'etc/beaver.conf')
default['beaver_hashes']['log_file'] = '/var/log/logstash/logstash_beaver.log'
default['beaver_hashes']['pid_file'] = '/var/run/logstash/logstash_beaver.pid'
